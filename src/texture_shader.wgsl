const planet_radius: f32 = 0.6;
const cloud_radius: f32 = 0.65;
const img_size: f32 = 512.0;
const light_src: vec3<f32> = vec3<f32>(1.0, 1.0, 1.0);

struct VertexInput {
    @location(0) position: vec3<f32>
}

struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) color: vec4<f32>
}

struct Color {
    one: vec3<f32>,
    two: vec3<f32>,
    three: vec3<f32>,
    four: vec3<f32>,
    five: vec3<f32>,
}

const Colors = array<Color, 6>(
    Color (
        vec3<f32>(0.91, 0.44, 0.32),
        vec3<f32>(0.73, 0.35, 0.25),
        vec3<f32>(0.55, 0.26, 0.19),
        vec3<f32>(0.36, 0.17, 0.13),
        vec3<f32>(0.18, 0.09, 0.06),
    ),
    Color (
        vec3<f32>(0.96, 0.64, 0.38),
        vec3<f32>(0.76, 0.51, 0.31),
        vec3<f32>(0.57, 0.38, 0.23),
        vec3<f32>(0.38, 0.25, 0.15),
        vec3<f32>(0.19, 0.13, 0.07),
    ),
    Color (
        vec3<f32>(0.91, 0.77, 0.42),
        vec3<f32>(0.73, 0.62, 0.33),
        vec3<f32>(0.55, 0.46, 0.25),
        vec3<f32>(0.36, 0.31, 0.16),
        vec3<f32>(0.18, 0.15, 0.08),
    ),
    Color (
        vec3<f32>(0.16, 0.62, 0.56),
        vec3<f32>(0.13, 0.49, 0.45),
        vec3<f32>(0.10, 0.37, 0.34),
        vec3<f32>(0.07, 0.25, 0.22),
        vec3<f32>(0.03, 0.12, 0.11),
    ),
    Color (
        vec3<f32>(0.15, 0.27, 0.33),
        vec3<f32>(0.12, 0.22, 0.26),
        vec3<f32>(0.09, 0.16, 0.20),
        vec3<f32>(0.06, 0.11, 0.13),
        vec3<f32>(0.03, 0.05, 0.07),
    ),
    Color (
        vec3<f32>(0.50, 0.93, 0.60),
        vec3<f32>(0.40, 0.75, 0.48),
        vec3<f32>(0.30, 0.56, 0.36),
        vec3<f32>(0.20, 0.37, 0.24),
        vec3<f32>(0.10, 0.18, 0.12),
    ),
);


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

fn map_planet_color(depth: f32) -> Color {
    if depth < 0.10 {
        return Colors[4];
    } else if depth < 0.30 {
        return Colors[3];
    } else if depth < 0.50 {
        return Colors[2];
    } else if depth < 0.70 {
        return Colors[1];
    } else {
        return Colors[0];
    }
}

fn get_shade(color: Color, shade: f32) -> vec3<f32> {
    if shade > 0.5 {
        return color.one;
    } else if shade > 0.3 {
        return color.two;
    } else if shade > 0.1 {
        return color.three;
    } else if shade > -0.10 {
        return color.four;
    } else {
        return color.five;
    }
}

fn get_lightness(p: vec3<f32>) -> f32 {
    let normalized = p / length(p);
    let light_norm = light_src / length(light_src);

    return dot(normalized, light_norm);
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
        let pos = vec3<f32>(
            x,
            y,
            sqrt(planet_radius*planet_radius - x*x - y*y)
        );
        let new_pos = rotate_point(pos, frame.t);

        let depth = pow(noise(vec4<f32>(new_pos, 0.1) * 10.0), 2.0);
        let color_tmp = map_planet_color(depth);
        let light_level = get_lightness(pos);
        color = vec4<f32>(get_shade(color_tmp, light_level), 1.0);
    }


    if distance(vec2<f32>(x, y), vec2<f32>(0.0)) < cloud_radius {
        let pos = vec3<f32>(
            x,
            y,
            sqrt(cloud_radius*cloud_radius - x*x - y*y)
        );
        let new_pos = rotate_point(pos, frame.t);

        let shade = pow(noise(vec4<f32>(new_pos, frame.t) * 10.0), 2.0);
        if shade > 0.3 {
            let light_level = get_lightness(pos);
            color = vec4<f32>(get_shade(Colors[5], light_level), 1.0);
        }
    }
    return color;
}
