#import <Cocoa/Cocoa.h>
#include <iostream>
#include <string>

// 一个简单的 C++ 封装窗口类
class MacWindow {
public:
    NSWindow* window;
    NSImageView* imageView;

    MacWindow(const std::string& title, int width, int height) {
        NSRect frame = NSMakeRect(100, 100, width, height);
        window = [[NSWindow alloc] initWithContentRect:frame
                                             styleMask:(NSWindowStyleMaskTitled |
                                                        NSWindowStyleMaskClosable |
                                                        NSWindowStyleMaskResizable)
                                               backing:NSBackingStoreBuffered
                                                 defer:NO];
        [window setTitle:[NSString stringWithUTF8String:title.c_str()]];
        [window makeKeyAndOrderFront:nil];

        // 初始化图片控件
        imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(50, 50, width-100, height-100)];
        [[window contentView] addSubview:imageView];
    }

    void setImage(const std::string& path) {
        NSImage* image = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:path.c_str()]];
        if (!image) {
            std::cout << "图片加载失败: " << path << std::endl;
            return;
        }
        [imageView setImage:image];
    }
};

// 主程序
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];

        MacWindow window("Astraia GUI", 800, 600);
        window.setImage("example.png");  // 替换成你自己的图片

        [app run]; // 进入事件循环
    }
    return 0;
}