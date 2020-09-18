import UIKit

class TransformView: UIView {
    
    private var viewTransform = CGAffineTransform.identity
    private var scale: CGFloat = 1.0
    private var translation:CGPoint = .zero
    private var rotation:CGFloat = 0
    var previousPoint = CGPoint.zero
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
                
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(hanlePanGesture(_ :)))
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(hanleRotationGesture(_ :)))
        
        addGestureRecognizer(pinchGesture)
        addGestureRecognizer(panGesture)
        addGestureRecognizer(rotationGesture)
        
    }
                 
    /// 单指旋转 和 缩放
    @objc private func pressRotate(_ ges: UIPanGestureRecognizer) {

        if ges.state == .began {

            previousPoint = ges.location(in: self)
            
            return

        }

        if ges.state == .changed {

            let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
            let currentPoint = ges.location(in: self)
            
            let previousDistance = distancePoint(center, otherPoint: previousPoint)
            let currentDistance = distancePoint(center, otherPoint: currentPoint)
            let newScale = currentDistance/previousDistance

            let angle = atan2f(Float(currentPoint.y - center.y), Float(currentPoint.x - center.x)) - atan2f(Float(previousPoint.y - center.y), Float(previousPoint.x - center.x))

            rotation = CGFloat(angle) + rotation

            scale *= newScale
            
            viewTransform.a = cos(rotation)
            viewTransform.d = cos(rotation)
            viewTransform.b = sin(rotation)
            viewTransform.c = -sin(rotation)
            viewTransform = viewTransform.scaledBy(x: scale, y: scale)
            imageView.transform = viewTransform

            previousPoint = currentPoint
            
            ges.setTranslation(.zero, in: imageView.superview)
            
        }

    }
    
    /// 恢复不想产生变换的控件
    func recoveryTransform() {
        var transform = CGAffineTransform.identity
        transform = transform.scaledBy(x: scale, y: scale)
        imageView.deleteButton.transform = transform.inverted()
        imageView.rotateButton.transform = transform.inverted()
    }
    
    func distancePoint(_ point:CGPoint, otherPoint:CGPoint) -> CGFloat {
        
        return sqrt(pow(point.x - otherPoint.x, 2) + pow(point.y - otherPoint.y, 2))
        
    }
    
    // 缩放
    @objc private func handlePinchGesture(_ ges: UIPinchGestureRecognizer) {
        
        if ges.state == .began || ges.state == .changed {

            let newScale = ges.scale
            scale = newScale * scale

            viewTransform.a = scale
            viewTransform.d = scale
            viewTransform.b = 0
            viewTransform.c = 0
            viewTransform = viewTransform.rotated(by: rotation)
            imageView.transform = viewTransform
                        
            ges.scale = 1

        }
        if ges.state == .ended {

        }
        
    }
        
    /// 平移
    @objc private func hanlePanGesture(_ ges: UIPanGestureRecognizer) {
        
        if ges.state == .began || ges.state == .changed {
            
            let newTranslation = ges.translation(in: imageView.superview)
            
            translation = CGPoint(x: newTranslation.x + translation.x, y: newTranslation.y + translation.y)
                                    
            viewTransform.tx = translation.x
            viewTransform.ty = translation.y
            imageView.transform = viewTransform
                        
            ges.setTranslation(.zero, in: imageView.superview)
            
        }
        if ges.state == .ended {
                        
        }
        
    }
    
    /// 旋转
    @objc private func hanleRotationGesture(_ ges: UIRotationGestureRecognizer) {
        
        if ges.state == .began || ges.state == .changed {
            
            let newRotation = ges.rotation
            
            rotation = newRotation + rotation
                    
            viewTransform.a = cos(rotation)
            viewTransform.d = cos(rotation)
            viewTransform.b = sin(rotation)
            viewTransform.c = -sin(rotation)
            viewTransform = viewTransform.scaledBy(x: scale, y: scale)
            imageView.transform = viewTransform
                        
            ges.rotation = 0
            
        }
        if ges.state == .ended {
                        
            
        }
        
    }
    
    /// 获取最终目标图片，存到相册
    func getFinalImage()  {
        
        UIImageWriteToSavedPhotosAlbum(getImageFromView(backImageView)!, nil, nil, nil)
                
    }
    
    func getImageFromView(_ view: UIView) -> UIImage? {
        return snapshotFromRender(view)
    }
    
    func snapshotFromRender(_ view: UIView) -> UIImage? {
        let renderer = UIGraphicsImageRenderer.init(size: view.bounds.size)
        let image = renderer.image { context in
            return view.layer.render(in: context.cgContext)
        }
        return image
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
