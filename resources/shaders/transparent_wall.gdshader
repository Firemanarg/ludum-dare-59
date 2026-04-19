shader_type canvas_item;

uniform sampler2D Cam1_texture;//The camera film wall
uniform sampler2D Cam2_texture;//The camera film target

uniform vec2 Target_Pos_PX = vec2(950.0,500.0);//Where center of the hole at
uniform float Radius = 200;//Radius of the hole
uniform float Edge_Smooth:hint_range(0.0, 500.0) = 80;//Smoothness of the hole
uniform vec2 Texture_Size = vec2(1920.0,1080.0);//How large the texture are

uniform float Pixelize_Edge:hint_range(0,1) = 0;//0 is false,1 is true
uniform float Pixel_Size_PX:hint_range(0.0, 25.0) = 23.791;//How big the pixelize edge pixel are


void fragment() {
	vec2 Pixel_Texture_Size = Texture_Size/Pixel_Size_PX;//Turn origin texture size into pixelize size
	float Distance = distance(SCREEN_UV * Texture_Size, Target_Pos_PX);//Calculate how close it is to the center of the circle
	float Pixel_Distance = distance(ceil(SCREEN_UV * Pixel_Texture_Size),Target_Pos_PX/Pixel_Size_PX);//Calculate how close it is to the center of the circle but pixelized

	vec4 Color1 = textureLod(Cam1_texture,SCREEN_UV,0.0);//sampling color from camera output
	vec4 Color2 = textureLod(Cam2_texture,SCREEN_UV,0.0);

	float Smooth_Mix_Result = smoothstep(Radius,Radius - Edge_Smooth, Distance);//Find out is this pixel in the circle's range
	float Pixel_Mix_Result = step(Pixel_Distance,Radius/Pixel_Size_PX);

	float Result_Mix_Index = mix(Smooth_Mix_Result,Pixel_Mix_Result,Pixelize_Edge);//blende smooth edge with pixelize edge
	COLOR = mix(Color1,Color2,Result_Mix_Index);//output final color
}