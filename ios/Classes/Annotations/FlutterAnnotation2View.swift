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
  private let triangleView = UIView()
  
  // 容器的宽
  private let containerWidth: CGFloat = 96
  // 容器的高
  private let containerHeight: CGFloat = 32

  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupView()
  }

  private func setupView() {
    // 设置基本属性
    canShowCallout = true // 点击是否显示小窗
    frame = CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight)

    // 设置容器视图 - 白色背景
    containerView.backgroundColor = UIColor.white
    containerView.layer.cornerRadius = 8
    containerView.layer.shadowColor = UIColor.black.cgColor
    containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
    containerView.layer.shadowOpacity = 0.1
    containerView.layer.shadowRadius = 4
    // containerView.layer.borderWidth = 1
    // containerView.layer.borderColor = UIColor.systemBlue.cgColor

    // 设置图像视图 - 左侧
    imageView.contentMode = .scaleAspectFit
    // imageView.tintColor = UIColor.systemBlue
    // imageView.backgroundColor = UIColor.systemPink
    // imageView.layer.cornerRadius = 16
    imageView.layer.masksToBounds = true

    // 设置标题标签 - 右侧
    titleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
    titleLabel.textColor = UIColor.black
    titleLabel.textAlignment = .left
    titleLabel.numberOfLines = 2
    titleLabel.lineBreakMode = .byTruncatingTail // 尾部省略号
    // titleLabel.text = "我的位置"

    // 设置三角形
    triangleView.backgroundColor = .white
    triangleView.layer.cornerRadius = 2
    triangleView.bounds = CGRect(x: 0, y: 0, width: 13, height: 13)
    triangleView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)

    // 添加子视图
    addSubview(containerView)
    containerView.addSubview(triangleView)
    containerView.addSubview(imageView)
    containerView.addSubview(titleLabel)
    
    containerView.transform = CGAffineTransform(scaleX: 1, y: 1)

    // 设置约束
    setupConstraints()
  }

  private func setupConstraints() {
    containerView.translatesAutoresizingMaskIntoConstraints = false
    triangleView.translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      // 容器视图约束 - 水平布局，更宽
      // containerView.topAnchor.constraint(equalTo: topAnchor),
      containerView.topAnchor.constraint(equalTo: topAnchor, constant: -containerHeight/2),
      containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
      // containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
      // containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
      containerView.widthAnchor.constraint(equalToConstant: containerWidth), // 增加宽度以适应左右布局
      containerView.heightAnchor.constraint(equalToConstant: containerHeight),

      // 三角形约束
      triangleView.centerXAnchor.constraint(equalTo: centerXAnchor),
      triangleView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4),
      triangleView.widthAnchor.constraint(equalToConstant: 8),
      triangleView.heightAnchor.constraint(equalToConstant: 8),

      // 图像视图约束 - 左侧
      imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
      imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
      imageView.widthAnchor.constraint(equalToConstant: 14),
      imageView.heightAnchor.constraint(equalToConstant: 14),

      // 标题标签约束 - 右侧
      titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 4),
      titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
      titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
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

  // 根据 annotation 的 isSelected 属性设置边框
  func updateSelected(with isSelected: Bool) {
    UIView.animate(withDuration: 0.3) {
      // self.containerView.alpha = 1
      if isSelected {
        NSLog("更新视图 ☑️ 选中")
        self.containerView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
      } else {
        NSLog("更新视图 ❌ 未选中")
        // self.containerView.transform = .identity
        self.containerView.transform = CGAffineTransform(scaleX: 1, y: 1)
      }
    }
  }
}
