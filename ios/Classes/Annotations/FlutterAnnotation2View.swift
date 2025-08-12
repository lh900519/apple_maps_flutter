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

  // 最大尺寸
  private let maxContainerWidth: CGFloat = 96
  private let maxContainerHeight: CGFloat = 32
  // 图像和间距的固定值
  private let imageWidth: CGFloat = 14
  private let imagePadding: CGFloat = 4
  private let labelPadding: CGFloat = 4
  
  // 字体大小
  private let fontSize: CGFloat = 10
      

  // 存储动态宽高约束
  private var containerWidthConstraint: NSLayoutConstraint!
  private var containerHeightConstraint: NSLayoutConstraint!

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
    canShowCallout = true
    frame = CGRect(x: 0, y: 0, width: maxContainerWidth, height: maxContainerHeight)

    // 设置容器视图
    containerView.backgroundColor = UIColor.white
    containerView.layer.cornerRadius = 8
    containerView.layer.shadowColor = UIColor.black.cgColor
    containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
    containerView.layer.shadowOpacity = 0.1
    containerView.layer.shadowRadius = 4

    // 设置图像视图
    imageView.contentMode = .scaleAspectFit
    imageView.layer.masksToBounds = true

    // 设置标题标签
    titleLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
    titleLabel.textColor = UIColor.black
    titleLabel.textAlignment = .left
    titleLabel.numberOfLines = 2
    titleLabel.lineBreakMode = .byTruncatingTail

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

    // 初始化为缩放状态，准备动画
    containerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)

    // 设置约束
    setupConstraints()
  }

  private func setupConstraints() {
    containerView.translatesAutoresizingMaskIntoConstraints = false
    triangleView.translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.translatesAutoresizingMaskIntoConstraints = false

    // 初始化动态宽高约束
    containerWidthConstraint = containerView.widthAnchor.constraint(equalToConstant: maxContainerWidth)
    containerHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: maxContainerHeight)

    NSLayoutConstraint.activate([
      // 容器视图约束
      containerView.topAnchor.constraint(equalTo: topAnchor, constant: -maxContainerHeight / 2),
      containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
      containerWidthConstraint,
      containerHeightConstraint,

      // 三角形约束
      triangleView.centerXAnchor.constraint(equalTo: centerXAnchor),
      triangleView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4),
      triangleView.widthAnchor.constraint(equalToConstant: 8),
      triangleView.heightAnchor.constraint(equalToConstant: 8),

      // 图像视图约束
      imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: imagePadding),
      imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
      imageView.widthAnchor.constraint(equalToConstant: imageWidth),
      imageView.heightAnchor.constraint(equalToConstant: imageWidth),

      // 标题标签约束
      titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: labelPadding),
      titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
      titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -labelPadding),
    ])
  }

  // 计算并更新容器尺寸
  private func updateContainerSize(for text: String?) {
    guard let text = text, !text.isEmpty else {
      // 没有文本时，使用最小尺寸（仅图像+间距）
      containerWidthConstraint.constant = imageWidth + 2 * imagePadding
      containerHeightConstraint.constant = imageWidth + 2 * imagePadding
      return
    }

    // 计算文本尺寸
    let maxTextWidth = maxContainerWidth - imageWidth - 2 * imagePadding - 2 * labelPadding
    let maxTextHeight = maxContainerHeight - 2 * imagePadding
    let textAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: fontSize, weight: .medium)]
    let textSize = (text as NSString).boundingRect(
      with: CGSize(width: maxTextWidth, height: maxTextHeight),
      options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
      attributes: textAttributes,
      context: nil
    ).size

    // 计算容器宽度
    let calculatedWidth = imageWidth + 2 * imagePadding + textSize.width + 2 * labelPadding
    let newWidth = min(calculatedWidth, maxContainerWidth)

    // 计算容器高度（考虑文本行数）
    let lineHeight = titleLabel.font.lineHeight // 使用 titleLabel 的行高
    let numberOfLines = min(ceil(textSize.height / lineHeight), 2) // 最多 2 行
    let calculatedHeight = max(imageWidth, numberOfLines * lineHeight) + 2 * imagePadding
    let newHeight = min(calculatedHeight, maxContainerHeight)

    // 更新约束
    containerWidthConstraint.constant = newWidth
    containerHeightConstraint.constant = newHeight
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    imageView.image = nil
    titleLabel.text = nil
    imageView.backgroundColor = UIColor.clear
    // 重置尺寸
    containerWidthConstraint.constant = maxContainerWidth
    containerHeightConstraint.constant = maxContainerHeight

    // 重置缩放
    containerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
  }

  func configure(with annotation: FlutterAnnotation) {
    self.annotation = annotation
    imageView.image = annotation.icon.image
    titleLabel.text = annotation.title

    // 根据文本更新容器尺寸
    updateContainerSize(for: annotation.title)

    // 添加从小到大的动画
    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
      self.containerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }, completion: nil)
  }

  func updateSelected(with isSelected: Bool) {
    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
      if isSelected {
        NSLog("更新视图 ☑️ 选中")
        self.containerView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
      } else {
        NSLog("更新视图 ❌ 未选中")
        self.containerView.transform = CGAffineTransform(scaleX: 1, y: 1)
      }
    }
  }
}
