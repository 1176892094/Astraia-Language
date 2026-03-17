#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

// 顶点数据
static const float vertex_data[] = {
     0.0f,  0.5f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.0f, 1.0f,
     0.5f, -0.5f, 0.0f, 1.0f
};

// MTKView Delegate
@interface Renderer : NSObject<MTKViewDelegate>
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLBuffer> vertexBuffer;
- (instancetype)initWithDevice:(id<MTLDevice>)device;
@end

@implementation Renderer

- (instancetype)initWithDevice:(id<MTLDevice>)device {
    if (self = [super init]) {
        _device = device;
        _commandQueue = [_device newCommandQueue];

        _vertexBuffer = [_device newBufferWithBytes:vertex_data
                                             length:sizeof(vertex_data)
                                            options:MTLResourceStorageModeShared];

        NSError *error = nil;

        // 内嵌 shader 字符串
        NSString *shaderSource = @"\
#include <metal_stdlib>\n\
using namespace metal;\n\
struct VertexOut { float4 position [[position]]; };\n\
vertex VertexOut vertex_main(const device float4* vertex_array [[buffer(0)]], uint id [[vertex_id]]) {\n\
    VertexOut out; out.position = vertex_array[id]; return out;\n\
}\n\
fragment float4 fragment_main() { return float4(1, 0, 0, 1); }";

        id<MTLLibrary> library = [_device newLibraryWithSource:shaderSource options:nil error:&error];
        if (!library) { NSLog(@"Failed to compile shader: %@", error); return nil; }

        id<MTLFunction> vertexFunc = [library newFunctionWithName:@"vertex_main"];
        id<MTLFunction> fragmentFunc = [library newFunctionWithName:@"fragment_main"];

        MTLRenderPipelineDescriptor *pipelineDesc = [[MTLRenderPipelineDescriptor alloc] init];
        pipelineDesc.vertexFunction = vertexFunc;
        pipelineDesc.fragmentFunction = fragmentFunc;
        pipelineDesc.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;

        _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineDesc error:&error];
        if (!_pipelineState) {
            NSLog(@"Failed to create pipeline: %@", error);
            return nil;
        }
    }
    return self;
}

// 渲染回调
- (void)drawInMTKView:(MTKView *)view {
    MTLRenderPassDescriptor *desc = view.currentRenderPassDescriptor;
    if (!desc || !view.currentDrawable) return;

    id<MTLCommandBuffer> cmdBuffer = [_commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [cmdBuffer renderCommandEncoderWithDescriptor:desc];

    [encoder setRenderPipelineState:_pipelineState];
    [encoder setVertexBuffer:_vertexBuffer offset:0 atIndex:0];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];

    [encoder endEncoding];
    [cmdBuffer presentDrawable:view.currentDrawable];
    [cmdBuffer commit];
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {}
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];

        NSRect frame = NSMakeRect(100, 100, 800, 600);
        NSWindow *window = [[NSWindow alloc] initWithContentRect:frame
                                                       styleMask:(NSWindowStyleMaskTitled |
                                                                  NSWindowStyleMaskClosable |
                                                                  NSWindowStyleMaskResizable)
                                                         backing:NSBackingStoreBuffered
                                                           defer:NO];
        [window setTitle:@"Metal Demo"];
        [window makeKeyAndOrderFront:nil];

        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        if (!device) {
            NSLog(@"Metal is not supported on this device");
            return -1;
        }

        MTKView *mtkView = [[MTKView alloc] initWithFrame:frame device:device];
        mtkView.clearColor = MTLClearColorMake(0.1, 0.2, 0.3, 1.0);
        [[window contentView] addSubview:mtkView];

        Renderer *renderer = [[Renderer alloc] initWithDevice:device];
        mtkView.delegate = renderer;

        [app run];
    }
    return 0;
}