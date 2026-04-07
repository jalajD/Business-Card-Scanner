import Foundation
import UIKit
import MLKitVision
import MLKitTextRecognition

class TextRecognitionService {
    static let shared = TextRecognitionService()

    private let textRecognizer: TextRecognizer

    private init() {
        textRecognizer = TextRecognizer.textRecognizer()
    }

    func recognizeText(from image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        let visionImage = VisionImage(image: image)
        visionImage.orientation = image.imageOrientation

        textRecognizer.process(visionImage) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let result = result else {
                completion(.failure(NSError(domain: "TextRecognitionService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No text recognized"])))
                return
            }

            completion(.success(result.text))
        }
    }
}
