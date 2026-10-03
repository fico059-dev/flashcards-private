// functions/src/index.ts
import {initializeApp} from "firebase-admin/app";

// RUN THIS IF YOU GET TYPESRIPT ERRORS WHEN DEPLOYING!!!!!
// ----------------------------------- npm i typescript@latest -------------------------------------------------------

initializeApp();

// IAP
export {verifyPurchase} from "./iap/router";
export {playRtdn} from "./iap/rtdn";

import {onCall} from "firebase-functions/v2/https";
import {addAdminRoleHandler} from "./handlers/addAdminRole";
import {deletePackProgressHandler} from "./handlers/deletePackProgress";
import {renamePackEverywhereHandler} from "./handlers/renamePackEverywhere";
import {deleteFlashcardEverywhereHandler} from "./handlers/deleteFlashcardEverywhere";
import {updateFlashcardEverywhereHandler} from "./handlers/updateFlashcardEverywhere";
import {createCustomSessionHandler} from "./handlers/createCustomSession";
import {devGrantHandler} from "./handlers/devGrant";
import {deletePackEverywhereHandler} from "./handlers/deletePackEverywhere";
import {deleteUserAndUserDataHandler} from "./handlers/deleteUserAndData";

export const deleteUserAndUserData = onCall(deleteUserAndUserDataHandler);

// admins
export const addAdminRole = onCall(addAdminRoleHandler);

// pack and pp_data operations
export const deletePackProgress = onCall(deletePackProgressHandler);
export const renamePackEverywhere = onCall(renamePackEverywhereHandler);
export const deletePackEverywhereIfEmpty = onCall(deletePackEverywhereHandler);

// flashcards operations
export const deleteFlashcardEverywhere = onCall(
  deleteFlashcardEverywhereHandler,
);
export const updateFlashcardEverywhere = onCall(
  updateFlashcardEverywhereHandler,
);

// fcp_data operations
export const createCustomSession = onCall(createCustomSessionHandler);

// subscription operations
export const devGrant = onCall(devGrantHandler);
