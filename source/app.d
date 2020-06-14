import std.stdio;

import bindbc.glfw;
import bindbc.opengl;
import bindbc.freetype;

import imagefmt;

import engine.shader;
import engine.texture;
import engine.window;

immutable string vertexShaderSource = q{
	#version 330 core

	layout (location = 0) in vec3 aPos;
	layout (location = 1) in vec3 aColor;
	layout (location = 2) in vec2 aTexCoord;

	out vec3 ourColor;
	out vec2 texCoord;

	void main()
	{
		gl_Position = vec4(aPos, 1.0);
		ourColor    = aColor;
		texCoord    = aTexCoord;
	}
};

immutable string fragmentShaderSource = q{
	#version 330 core

	in vec3 ourColor;
	in vec2 texCoord;

	out vec4 fragColor;

	uniform sampler2D texture1;
	uniform sampler2D texture2;
	uniform float blend;

	void main()
	{
		fragColor = mix(texture(texture1, texCoord), texture(texture2, vec2(texCoord.x, 1.0 - texCoord.y)), blend);
	}
};

immutable float[] vertices = [
    // positions          // colors           // texture coords
     0.5f,  0.5f, 0.0f,   1.0f, 0.0f, 0.0f,   1.0f, 1.0f,   // top right
     0.5f, -0.5f, 0.0f,   0.0f, 1.0f, 0.0f,   1.0f, 0.0f,   // bottom right
    -0.5f, -0.5f, 0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 0.0f,   // bottom left
    -0.5f,  0.5f, 0.0f,   1.0f, 1.0f, 0.0f,   0.0f, 1.0f    // top left 
];

immutable float[] texCoords = [
	0.0f, 0.0f,
	1.0f, 0.0f,
	0.5f, 1.0f
];

immutable uint[] indices = [
    0, 1, 3,   // first triangle
    1, 2, 3   // second triangle
];

void main()
{
	prepareGLFW();

	scope (exit)
	{
		glfwTerminate();
	}

	WindowConfig windowConfig = {
		title: "Test Window",
		width: 800,
		height: 600
	};

	Window window = Window(windowConfig);
	window.makeContextCurrent();

	prepareOpenGL();
	window.setFramebufferSizeCallback(&framebufferSizeCallback);

	ShaderConfig[] shaderConfig = [
		{
			source: vertexShaderSource,
			type:   GL_VERTEX_SHADER
		},
		{
			source: fragmentShaderSource,
			type:   GL_FRAGMENT_SHADER
		}
	];

	auto shader = Shader(shaderConfig);

	auto VAOs = createVertexArrayObjects(1);
	auto VBOs = createVertexBufferObjects(VAOs, vertices);
	uint EBO = createElementBufferObject(indices);

	TextureConfig textureConfig1;
	Texture texture1 = Texture(textureConfig1);
	texture1.load("assets/container.jpg");

	TextureConfig textureConfig2;
	Texture texture2 = Texture(textureConfig2);
	texture2.load("assets/face.png");

	while (!window.shouldClose)
	{
		processInput(window);

		glClearColor(0.2, 0.3, 0.3, 1.0);
		glClear(GL_COLOR_BUFFER_BIT);

		foreach (index, VAO; VAOs)
		{
			shader.use();
			shader.setInt("texture1", 0);
			shader.setInt("texture2", 1);
			shader.setFloat("blend", blend);

			glActiveTexture(GL_TEXTURE0);
			texture1.bind();

			glActiveTexture(GL_TEXTURE1);
			texture2.bind();

			glBindVertexArray(VAO);
			glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, null);
		}

		glBindVertexArray(0);

		window.swapBuffers();
		glfwPollEvents();
	}

	writeln("Done.");
}

private uint createTexture(string filename, uint channels, uint format)
{
	uint texture;

	glGenTextures(1, &texture);
	glBindTexture(GL_TEXTURE_2D, texture);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	auto image = loadImageAsset(filename, channels);
	assert(!image.e, "Failed to load Image Asset");
	scope (exit) image.free();

	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, image.w, image.h, 0, format, GL_UNSIGNED_BYTE, image.buf8.ptr);
	glGenerateMipmap(GL_TEXTURE_2D);

	return texture;
}

private IFImage loadImageAsset(string filename, uint channels)
{
	return read_image(filename, channels);
}

private uint[] createVertexArrayObjects(uint count)
{
	uint[] VAOs = new uint[count];

	glGenVertexArrays(cast(uint) VAOs.length, VAOs.ptr);

	return VAOs;
}

private uint[] createVertexBufferObjects(uint[] VAOs, in float[][] vertexLists...)
{
	uint[] VBOs = new uint[vertexLists.length];

	glGenBuffers(cast(uint) vertexLists.length, VBOs.ptr);

	foreach (index, vertices; vertexLists)
	{
		glBindVertexArray(VAOs[index]);
		glBindBuffer(GL_ARRAY_BUFFER, VBOs[index]);
		glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof, vertices.ptr, GL_STATIC_DRAW);

		glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * float.sizeof, cast(void*) 0);
		glEnableVertexAttribArray(0);
	
		glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * float.sizeof, cast(void*)(3 * float.sizeof));
		glEnableVertexAttribArray(1);

		glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * float.sizeof, cast(void*)(6 * float.sizeof));
		glEnableVertexAttribArray(2);
	}

	return VBOs;
}

private uint createElementBufferObject(in uint[] indices)
{
	uint EBO;

	glGenBuffers(1, &EBO);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.length * uint.sizeof, indices.ptr, GL_STATIC_DRAW);

	return EBO;
}

private extern (C) void framebufferSizeCallback(GLFWwindow* window, int width, int height) nothrow
{
	glViewport(0, 0, width, height);
}

private float blend = 0.2;

private void processInput(ref Window window)
{
	import std.algorithm : min, max;

	if (window.getKey(GLFW_KEY_ESCAPE) == GLFW_PRESS)
	{
		window.shouldClose = true;
	}
	if (window.getKey(GLFW_KEY_UP) == GLFW_PRESS)
	{
		blend = min(1.0, blend + 0.01);
	}
	if (window.getKey(GLFW_KEY_DOWN) == GLFW_PRESS)
	{
		blend = max(0.0, blend - 0.01);
	}
}

void prepareGLFW()
{
	GLFWSupport result = loadGLFW();

    switch (result)
    {
        case GLFWSupport.badLibrary:
            assert(0, "Bad library");

        case GLFWSupport.noLibrary:
            assert(0, "Missing GLFW.");

        default:
            writefln("Loaded GLFW (%s)", result);
    }

    glfwInit();

    glfwWindowHint(GLFW_CLIENT_API, GLFW_OPENGL_API);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 1);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE);

    glfwSetErrorCallback(&appGlobalErrorHandler);
}

private extern (C) void appGlobalErrorHandler(int code, const(char)* message) nothrow
{
    printf("Error(%d, 0x%x): %s\n", code, code, message);
}

void prepareOpenGL()
{
	GLSupport result = loadOpenGL();

    switch (result)
    {
        case GLSupport.badLibrary:
            assert(0, "Bad library");

        case GLSupport.noLibrary:
            assert(0, "Missing OpenGL.");

        default:
            writefln("Loaded OpenGL (%s)", result);
    }
}

void prepareFreeType()
{
	FTSupport result = loadFreeType("freetype.dll");

    switch (result)
    {
        case FTSupport.badLibrary:
            assert(0, "Bad library");

        case FTSupport.noLibrary:
            assert(0, "Missing FreeType.");

        default:
            writefln("Loaded FreeType (%s)", result);
    }
}
