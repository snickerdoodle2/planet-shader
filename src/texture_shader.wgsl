const planet_radius: f32 = 0.5;
const cloud_radius: f32 = 0.55;
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

struct Colors {
    water: vec3<f32>,
}

fn rotate_point(p: vec3<f32>, t: f32) -> vec3<f32> {
    let pi = atan(1.0) * 4.0;
    let angle = 2.0 * pi * t;

    let matrix = mat3x3(
        vec3<f32>( cos(angle), 0.0,  sin(angle)),
        vec3<f32>(        0.0, 1.0,         0.0),
        vec3<f32>(-sin(angle), 0.0,  cos(angle))
    );

    return matrix * p;
}

fn map_color(depth: f32) -> vec3<f32> {
    if depth < 0.10 {
        return vec3<f32>(0.11, 0.16, 0.40);
    } else if depth < 0.25 {
        return vec3<f32>(0.29, 0.35, 0.53);
    } else if depth < 0.30 {
        return vec3<f32>(0.80, 0.70, 0.25);
    } else if depth < 0.50 {
        return vec3<f32>(0.36, 0.50, 0.27);
    } else if depth < 0.70 {
        return vec3<f32>(0.24, 0.38, 0.21);
    } else {
        return vec3<f32>(0.76, 0.78, 0.79);
    }
}

struct FrameUniform {
    t: f32,
}

@group(0) @binding(0)
var<uniform> frame: FrameUniform;

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let x = in.clip_position.x / img_size * 2.0 - 1.0;
    let y = in.clip_position.y / img_size * 2.0 - 1.0;

    var color: vec4<f32> = vec4<f32>(0.0, 0.0, 0.0, 1.0);

    if distance(vec2<f32>(x, y), vec2<f32>(0.0)) < planet_radius {
        var pos: vec3<f32> = vec3<f32>(
            x,
            y,
            sqrt(planet_radius*planet_radius - x*x - y*y)
        );
        pos = rotate_point(pos, frame.t);

        let shade = pow(noise(vec4<f32>(pos, 0.1) * 10.0), 2.0);
        color = vec4<f32>(map_color(shade), 1.0);
    }

    if distance(vec2<f32>(x, y), vec2<f32>(0.0)) < cloud_radius {
        var pos: vec3<f32> = vec3<f32>(
            x,
            y,
            sqrt(cloud_radius*cloud_radius - x*x - y*y)
        );
        pos = rotate_point(pos, frame.t);

        let shade = pow(noise(vec4<f32>(pos, frame.t) * 10.0), 2.0);
        if shade > 0.3 {
            color = vec4<f32>(0.95, 0.95, 0.95, 1.0);
        }
    }
    return color;
}
