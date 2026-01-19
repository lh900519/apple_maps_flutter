import Flutter
import UIKit

public class SwiftAppleMapsFlutterPlugin: NSObject, FlutterPlugin {
    var factory: AppleMapViewFactory
    private var staticMethods: AppleMapsStaticMethods?
  
  
    public init(with registrar: FlutterPluginRegistrar) {
        factory = AppleMapViewFactory(withRegistrar: registrar)
        super.init()
        
        // 注册 PlatformView
        registrar.register(
          factory,
          withId: "apple_maps_plugin.luisthein.de/apple_maps",
          gestureRecognizersBlockingPolicy:FlutterPlatformViewGestureRecognizersBlockingPolicyWaitUntilTouchesEnded,
        )
  
        // 初始化静态方法处理器
        staticMethods = AppleMapsStaticMethods(with: registrar)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        registrar.addApplicationDelegate(SwiftAppleMapsFlutterPlugin(with: registrar))
    }
}
