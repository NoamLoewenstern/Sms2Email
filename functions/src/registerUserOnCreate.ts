import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { FieldValue } from 'firebase-admin/firestore';

// firebase Trigger on user auth creation add to collection users
const usersCollectionName = 'users';
export const registerUserOnCreate = functions.auth.user().onCreate(user => {
  return admin.firestore().collection(usersCollectionName).doc(user.uid).set({
    email: user.email,
    displayName: user.displayName,
    // photoURL: user.photoURL,
    // phoneNumber: user.phoneNumber,
    createdAt: FieldValue.serverTimestamp(),
  });
});
