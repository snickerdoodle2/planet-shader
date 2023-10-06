const radius: f32 = 0.5;
const img_size: f32 = 512.0;
struct VertexInput {
    @location(0) position: vec3<f32>
}

struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) color: vec4<f32>
}

@vertex
fn vs_main(model: VertexInput) -> VertexOutput {
    var out: VertexOutput;
    out.clip_position = vec4<f32>(model.position, 1.0);
    out.color = vec4<f32>(model.position, 1.0);
    return out;
}

fn rand(p: vec4<f32>) -> f32 {
    return fract(sin(p.x*1234. + p.y*2345. + p.z*3456. + p.w*4567.) * 5678.);
}

const e: vec2<f32> = vec2(0.0, 1.0);
fn smooth_noise(p: vec4<f32>) -> f32 {
    let i = floor(p);
    var f: vec4<f32> = fract(p);

    f = f * f * (3. - 2. * f);

    return mix(mix(mix(mix(rand(i + e.xxxx),
                           rand(i + e.yxxx), f.x),
                       mix(rand(i + e.xyxx),
                           rand(i + e.yyxx), f.x), f.y),
                   mix(mix(rand(i + e.xxyx),
                           rand(i + e.yxyx), f.x),
                       mix(rand(i + e.xyyx),
                           rand(i + e.yyyx), f.x), f.y), f.z),
               mix(mix(mix(rand(i + e.xxxy),
                           rand(i + e.yxxy), f.x),
                       mix(rand(i + e.xyxy),
                           rand(i + e.yyxy), f.x), f.y),
                   mix(mix(rand(i + e.xxyy),
                           rand(i + e.yxyy), f.x),
                       mix(rand(i + e.xyyy),
                           rand(i + e.yyyy), f.x), f.y), f.z), f.w);
}

fn noise(p: vec4<f32>) -> f32 {
    var s: f32 = 0.0;
    var pow2: f32 = 1.0;

    for (var i: i32 = 0; i < 5; i++) {
        s += smooth_noise(p * pow2) / pow2;
        pow2 *= 2.0;
    }
    return s / 2.0;
}

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let x = in.clip_position.x / img_size * 2.0 - 1.0;
    let y = in.clip_position.y / img_size * 2.0 - 1.0;

    if distance(vec2<f32>(x, y), vec2<f32>(0.0)) <= radius {
        let pos = vec3<f32>(
            x,
            y,
            sqrt(radius*radius - x*x - y*y)
        );

        let shade = pow(noise(vec4<f32>(pos, 0.1) * 10.0), 2.0);
        return vec4<f32>(shade, shade, shade, 1.0);
    }
    return vec4<f32>(0.0, 0.0, 0.0, 1.0);
}
