import {getAuth} from "firebase-admin/auth";
import {logger} from "firebase-functions";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {checkIfAdminAndThrow} from "../utils/utils";

export enum Roles {
  admin = "admin",
}

export async function addAdminRoleHandler(request: CallableRequest) {
  try {
    const {auth, data} = request;
    checkIfAdminAndThrow(auth);

    const email: string | undefined = data.email;
    if (!email) {
      logger.error("Missing required parameter: email");
      throw new HttpsError(
        "invalid-argument",
        "Missing required parameter: email",
      );
    }

    const user = await getAuth().getUserByEmail(email);
    const userRoles: string[] = user.customClaims?.roles || [];
    if (userRoles.includes(Roles.admin)) {
      logger.info("User already has admin role", {targetEmail: email});
      throw new HttpsError("already-exists", "User already has admin role");
    }
    await getAuth().setCustomUserClaims(user.uid, {roles: [Roles.admin]});

    logger.info("Admin role granted", {
      performedBy: auth.uid,
      grantedFor: user.uid,
    });
    return {success: true};
  } catch (error: any) {
    if (error instanceof HttpsError) throw error;
    logger.error("addAdminRole failed", {error});
    throw new HttpsError("internal", error.message || "Internal error");
  }
}
