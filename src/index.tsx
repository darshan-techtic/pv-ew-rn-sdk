import { NativeModules } from 'react-native';
const { PVWebAPIModel } = NativeModules;

//Get signing key
export async function getSigningKey(email: string) {
  try {
    return new Promise((resolve, reject) => {
      PVWebAPIModel.getSigningKey(email, (response: any) => {
        if (response) {
          resolve(response);
        } else {
          reject('No response received');
        }
      });
    });
  } catch (error) {
    console.error('Failed to get signing key: ', error);
    throw error;
  }
}

export async function isBackupActiveAPI(userId: string, orgId: string) {
  try {
    return new Promise((resolve, reject) => {
      PVWebAPIModel.isBackupActive(userId, orgId, (completionHandler: any) => {
        if (completionHandler) {
          resolve(completionHandler);
        } else {
          reject('No response received');
        }
      });
    });
  } catch (error) {
    console.error('Failed to get signing key: ', error);
    throw error;
  }
}
