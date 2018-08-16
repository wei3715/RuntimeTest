# RuntimeTest
运行时机制测试，category 添加属性测试

消息转发：
也是Runtime的黑魔法，其中一个用处就是可以实现多继承，当发送消息后找不到对应的方法实现时，会经过如下过程:
动态方法解析: 通过resolveInstanceMethod:方法，检查是否通过@dynamic动态添加了方法。
直接消息转发: 不修改原本方法签名，直接检查forwardingTargetForSelector:是否实现，若返回非nil且非self，则向该返回对象直接转发消息。
标准消息转发: 先处理方法调用再转发消息，重写methodSignatureForSelector:和forwardInvocation:方法，前者用于为该消息创建一个合适的方法签名，后者则是将该消息转发给其他对象。
上述过程均未实现，则程序异常。
