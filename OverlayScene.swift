//
//  OverlayScene.swift
//  gggggg
//
//  Created by Mishunin on 19.12.2021.
//

import SpriteKit
import Vision


protocol OverlaySceneDelegate: AnyObject {
    func respondToSwipe(_ direction: UISwipeGestureRecognizer.Direction)
}

class OverlayScene: SKScene {
    weak var overlaySceneDelegate: OverlaySceneDelegate?
    private var resultsLabel = UILabel()
    private lazy var canvasView: CanvasView = {
        return CanvasView(frame: frame)
    }()
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let c = MLModelConfiguration() //todo
            
            let visionModel = try VNCoreMLModel(for: MyImageClassifier(configuration: MLModelConfiguration()).model)
            let request = VNCoreMLRequest(model: visionModel, completionHandler: { [weak self] request, error in
                self?.isRecoqnizing = false
                self?.processObservations(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to create VNCoreMLModel: \(error)")
        }
    }()
    private var isRecoqnizing: Bool = false
    
    override init(size: CGSize) {
        super.init(size: size)
        //todo
        
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        isUserInteractionEnabled = true
        
        canvasView.delegate = self
        canvasView.backgroundColor = .white
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvasView)
        
        NSLayoutConstraint.activate([
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.topAnchor),
            canvasView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }
    
    func classify(image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            print("Unable to create CIImage")
            return
        }
        isRecoqnizing = true
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: .up)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                print("Failed to perform classification: \(error)")
            }
        }
    }
    
    func processObservations(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            if let results = request.results as? [VNClassificationObservation] {
                if results.isEmpty {
                    print("nothing found")
                } else {
//                    results.forEach { it in
//                        print("\(it.identifier): \(it.confidence)")
//                    }
                    print("\(results[0].identifier): \(results[0].confidence)")
                }
            } else if let error = error {
                print("error: \(error.localizedDescription)")
            } else {
                print("???")
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first?.location(in: view) else { return }
        canvasView.OnMainViewTouchBegan(touch)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first?.location(in: view) else { return }
        canvasView.OnMainViewTouchMoved(touch)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first?.location(in: view) else { return }
        canvasView.OnMainViewTouchEnded(touch)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension OverlayScene: CanvasDelegate {
    func didSwiped(_ dir: UISwipeGestureRecognizer.Direction) {
        overlaySceneDelegate?.respondToSwipe(dir)
    }
    
    func didEndDrawing() {
        if !isRecoqnizing {
            guard let view = view, let img = canvasView.snapshot() else { return }
            classify(image: img)
            
            let imgView = UIImageView(image: img)
            view.addSubview(imgView)
            imgView.backgroundColor = .red
            imgView.contentScaleFactor = 0.5
            imgView.frame.origin.x = 0
            imgView.frame.origin.y = view.frame.size.height - imgView.bounds.height
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [unowned self] in
                imgView.removeFromSuperview()
                self.canvasView.clear()
            }
        }
            
        
    }
}
