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

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let dis = distance(in.clip_position, vec4(64.0, 64.0, 0.0, 2.0));
    if dis < 30.0 {
        let x = in.clip_position[0];
        let y = in.clip_position[1];
        let z = sqrt(30.0 - x*x - y*y);
        return vec4<f32>(x, y, z, 1.0);
    }
    return vec4<f32>(0.0, 0.0, 0.0, 1.0);
}
