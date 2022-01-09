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
                print("Request is finished!", request.results as Any)
                self?.processObservations(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to create VNCoreMLModel: \(error)")
        }
    }()
    
//    override var isUserInteractionEnabled: Bool {
//            get { return true }
//            set { }
//        }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
       
        
//        let swipeGestureRecognizerLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
//        view.addGestureRecognizer(swipeGestureRecognizerLeft)
//        swipeGestureRecognizerLeft.direction = .left
//        
//        let swipeGestureRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
//        view.addGestureRecognizer(swipeGestureRecognizerRight)
//        swipeGestureRecognizerRight.direction = .right
//        
//        let swipeGestureRecognizerUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
//        view.addGestureRecognizer(swipeGestureRecognizerUp)
//        swipeGestureRecognizerUp.direction = .up
//        
//        let swipeGestureRecognizerDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
//        view.addGestureRecognizer(swipeGestureRecognizerDown)
//        swipeGestureRecognizerDown.direction = .down
    }
    
    func classify(image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            print("Unable to create CIImage")
            return
        }
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
                    self.resultsLabel.text = "nothing found"
                } else {
                    results.forEach { it in
                        print("\(it.identifier): \(it.confidence)")
                    }
                    self.resultsLabel.text = "\(results[0].identifier): \(results[0].confidence)"
                }
            } else if let error = error {
                self.resultsLabel.text = "error: \(error.localizedDescription)"
            } else {
                self.resultsLabel.text = "???"
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

}

extension OverlayScene: CanvasDelegate {
    func didSwiped(_ dir: UISwipeGestureRecognizer.Direction) {
        overlaySceneDelegate?.respondToSwipe(dir)
    }
    
    func didEndDrawing() {
        guard let view = view, let img = canvasView.snapshot() else { return }
        classify(image: img)
        
            let imgView = UIImageView(image: img)
            view.addSubview(imgView)
            imgView.backgroundColor = .red
            imgView.center = view.center
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [unowned self] in
            imgView.removeFromSuperview()
            self.canvasView.clear()
        }
    }
}
