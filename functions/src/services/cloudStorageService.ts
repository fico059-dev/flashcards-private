import {getStorage} from "firebase-admin/storage";

class CloudStorageService {
  private _bucket;
  private constructor() {
    this._bucket = getStorage().bucket();
  }

  private static _instance: CloudStorageService;

  public static get instance(): CloudStorageService {
    if (!CloudStorageService._instance) {
      CloudStorageService._instance = new CloudStorageService();
    }

    return CloudStorageService._instance;
  }

  // Flashcard images
  _flashcardRef(flashcardId: string): string {
    return `flashcards/${flashcardId}`;
  }

  // / It gives you reference to the flashcard's question image, the path looks like this:
  // / /flashcards/{flashcardId}/question.jpg
  getFlashcardQuestionImageRef(flashcardId: string) {
    const path = `${this._flashcardRef(flashcardId)}/question.jpg`;
    return this._bucket.file(path);
  }

  // / It gives you reference to the flashcard's answer image, the path looks like this:
  // / /flashcards/{flashcardId}/question.jpg
  getFlashcardAnswerImageRef(flashcardId: string) {
    const path = `${this._flashcardRef(flashcardId)}/answer.jpg`;
    return this._bucket.file(path);
  }
}

// export const cloudStorageService = CloudStorageService.getInstance();
export {CloudStorageService};
