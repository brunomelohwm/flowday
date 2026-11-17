const { readFileSync } = require('node:fs');
const { after, before, beforeEach, test } = require('node:test');
const assert = require('node:assert/strict');
const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');
const {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  getFirestore,
  setDoc,
  updateDoc,
} = require('firebase/firestore');

const projectId = 'demo-flowday-rules';
let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: {
      rules: readFileSync('../firestore.rules', 'utf8'),
    },
  });
});

beforeEach(async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'users/alice'), { name: 'Alice' });
    await setDoc(doc(db, 'users/alice/tasks/task-1'), { title: 'Initial task' });
    await setDoc(doc(db, 'users/bob'), { name: 'Bob' });
    await setDoc(doc(db, 'users/bob/tasks/task-1'), { title: 'Bob task' });
  });
});

after(async () => {
  await testEnv?.cleanup();
});

test('unauthenticated users cannot read or write profiles or tasks', async () => {
  const db = testEnv.unauthenticatedContext().firestore();
  const profile = doc(db, 'users/alice');
  const task = doc(db, 'users/alice/tasks/task-1');
  const tasks = collection(db, 'users/alice/tasks');

  await assertFails(getDoc(profile));
  await assertFails(setDoc(doc(db, 'users/new-user'), { name: 'New' }));
  await assertFails(updateDoc(profile, { name: 'Changed' }));
  await assertFails(deleteDoc(profile));

  await assertFails(getDoc(task));
  await assertFails(getDocs(tasks));
  await assertFails(setDoc(doc(db, 'users/alice/tasks/new-task'), { title: 'New' }));
  await assertFails(updateDoc(task, { title: 'Changed' }));
  await assertFails(deleteDoc(task));
});

test('an owner can read and mutate their profile and task collection', async () => {
  const db = testEnv.authenticatedContext('alice').firestore();
  const profile = doc(db, 'users/alice');
  const task = doc(db, 'users/alice/tasks/task-1');
  const newTask = doc(db, 'users/alice/tasks/task-2');

  await assertSucceeds(getDoc(profile));
  await assertSucceeds(updateDoc(profile, { name: 'Alice updated' }));
  await assertSucceeds(setDoc(doc(db, 'users/alice'), { name: 'Alice replaced' }));
  await assertSucceeds(getDocs(collection(db, 'users/alice/tasks')));
  await assertSucceeds(getDoc(task));
  await assertSucceeds(setDoc(newTask, { title: 'Created by Alice' }));
  await assertSucceeds(updateDoc(newTask, { title: 'Updated by Alice' }));
  await assertSucceeds(deleteDoc(newTask));
  await assertSucceeds(deleteDoc(task));
  await assertSucceeds(deleteDoc(profile));
});

test('a user can create their profile, but another user cannot create it', async () => {
  const ownerDb = testEnv.authenticatedContext('charlie').firestore();
  const otherUserDb = testEnv.authenticatedContext('bob').firestore();

  await assertSucceeds(setDoc(doc(ownerDb, 'users/charlie'), { name: 'Charlie' }));
  await assertFails(setDoc(doc(otherUserDb, 'users/dana'), { name: 'Dana' }));
});

test('a different user cannot access or mutate another user profile or tasks', async () => {
  const db = testEnv.authenticatedContext('bob').firestore();
  const profile = doc(db, 'users/alice');
  const task = doc(db, 'users/alice/tasks/task-1');
  const tasks = collection(db, 'users/alice/tasks');

  await assertFails(getDoc(profile));
  await assertFails(setDoc(profile, { name: 'Impersonated' }));
  await assertFails(updateDoc(profile, { name: 'Changed by Bob' }));
  await assertFails(deleteDoc(profile));

  await assertFails(getDoc(task));
  await assertFails(getDocs(tasks));
  await assertFails(setDoc(doc(db, 'users/alice/tasks/bob-task'), { title: 'Injected' }));
  await assertFails(updateDoc(task, { title: 'Changed by Bob' }));
  await assertFails(deleteDoc(task));
});
