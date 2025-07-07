//
//  FlutterAnnotation2View.swift
//  Pods
//
//  Created by liuhaibo on 2025/7/6.
//

import Foundation
import MapKit

class FlutterAnnotation2View: MKAnnotationView {
  private let containerView = UIView()
  private let imageView = UIImageView()
  private let titleLabel = UILabel()
  private let triangleView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupView()
  }

    private func setupView1() {
        // 设置标注视图的属性
        canShowCallout = true // 启用默认的标注弹窗
        image = UIImage(named: "customPin") // 设置自定义图片
        frame = CGRect(x: 0, y: 0, width: 40, height: 40) // 设置视图大小

        // 添加自定义子视图（例如标签或按钮）
        let label = UILabel(frame: CGRect(x: 0, y: 40, width: 40, height: 20))
        label.text = "Pin"
        label.textAlignment = .center
        label.textColor = .black
        label.backgroundColor = .white
        addSubview(label)
    }

  private func setupView() {
    // 设置基本属性
    canShowCallout = true

    // 设置容器视图 - 白色背景
    containerView.backgroundColor = UIColor.white
    containerView.layer.cornerRadius = 10
    containerView.layer.shadowColor = UIColor.black.cgColor
    containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
    containerView.layer.shadowOpacity = 0.3
    containerView.layer.shadowRadius = 10
    // containerView.layer.borderWidth = 1
    // containerView.layer.borderColor = UIColor.systemBlue.cgColor
    
    // 设置图像视图 - 左侧
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = UIColor.systemBlue
    imageView.backgroundColor = UIColor.systemPink
    imageView.layer.cornerRadius = 16
    imageView.layer.masksToBounds = true
    
    // 设置标题标签 - 右侧
    titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    titleLabel.textColor = UIColor.black
    titleLabel.textAlignment = .left
    titleLabel.numberOfLines = 1
    // titleLabel.text = "我的位置"

    // 设置三角形
    triangleView.bounds = CGRect(x: 0, y: 0, width: 16, height: 16)
    triangleView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)


    // 添加子视图
    addSubview(containerView)
    addSubview(triangleView)
    containerView.addSubview(imageView)
    containerView.addSubview(titleLabel)

    // 设置约束
    setupConstraints()
  }

  private func setupConstraints() {
      containerView.translatesAutoresizingMaskIntoConstraints = false
      imageView.translatesAutoresizingMaskIntoConstraints = false
      titleLabel.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
          // 容器视图约束 - 水平布局，更宽
          // containerView.topAnchor.constraint(equalTo: topAnchor),
          containerView.topAnchor.constraint(equalTo: topAnchor, constant: -20),
          containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
          //containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
          //containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
          containerView.widthAnchor.constraint(equalToConstant: 120), // 增加宽度以适应左右布局
          containerView.heightAnchor.constraint(equalToConstant: 40),
          
          // 三角形约束
          triangleView.centerXAnchor.constraint(equalTo: centerXAnchor),
          triangleView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8),
          triangleView.widthAnchor.constraint(equalToConstant: 16),
          triangleView.heightAnchor.constraint(equalToConstant: 16),
          
          // 图像视图约束 - 左侧
          imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
          imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
          imageView.widthAnchor.constraint(equalToConstant: 18),
          imageView.heightAnchor.constraint(equalToConstant: 18),

          // 标题标签约束 - 右侧
          titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5),
          titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
          //titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
      ])
  }
  
  override func prepareForReuse() {
      super.prepareForReuse()
      imageView.image = nil
      titleLabel.text = nil
      imageView.backgroundColor = UIColor.clear
  }

  func configure(with annotation: FlutterAnnotation) {
          self.annotation = annotation
          
          // imageView.tintColor = UIColor.white
          imageView.image = annotation.icon.image
    
          // 设置标题
          titleLabel.text = annotation.title
      }
}
