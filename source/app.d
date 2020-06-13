import std.stdio;

import bindbc.glfw;
import bindbc.opengl;
import bindbc.freetype;

import utils.shader;

immutable string vertexShaderSource = q{
	#version 330 core

	layout (location = 0) in vec3 aPos;
	layout (location = 1) in vec3 aColor;

	out vec3 ourColor;

	void main()
	{
		gl_Position = vec4(aPos, 1.0);
		ourColor    = aColor;
	}
};

immutable string fragmentShaderSource = q{
	#version 330 core

	in vec3 ourColor;

	out vec4 fragColor;

	void main()
	{
		fragColor = vec4(ourColor, 1.0f);
	}
};

immutable float[] triangle = [
    // positions         // colors
     0.5f, -0.5f, 0.0f,  1.0f, 0.0f, 0.0f,   // bottom right
    -0.5f, -0.5f, 0.0f,  0.0f, 1.0f, 0.0f,   // bottom left
     0.0f,  0.5f, 0.0f,  0.0f, 0.0f, 1.0f    // top 
];

immutable uint[] indices = [
    0, 1, 2,   // first triangle
    3, 4, 5   // second triangle
];

void main()
{
	prepareGLFW();

	scope (exit)
	{
		glfwTerminate();
	}

	GLFWwindow* window = glfwCreateWindow(800, 600, "Test", null, null);
	assert(window, "Failed to create GLFW Window.");
	glfwMakeContextCurrent(window);
	
	prepareOpenGL();
	glfwSetFramebufferSizeCallback(window, &framebufferSizeCallback);

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
	auto VBOs = createVertexBufferObjects(VAOs, triangle);
	uint EBO = createElementBufferObject(indices);

	while (!glfwWindowShouldClose(window))
	{
		processInput(window);

		glClearColor(0.2, 0.3, 0.3, 1.0);
		glClear(GL_COLOR_BUFFER_BIT);

		import std.math : sin;

		float timeValue  = glfwGetTime();
		float greenValue = (sin(timeValue) / 2.0f) + 0.5f;

		foreach (index, VAO; VAOs)
		{
			int vertexColorLocation = shader.uniformLocation("ourColor");

			shader.use();
			glUniform4f(vertexColorLocation, 0.0f, greenValue, 0.0f, 1.0f);

			glBindVertexArray(VAO);
			glDrawArrays(GL_TRIANGLES, 0, 3);
		}
		// glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, null);
		glBindVertexArray(0);

		glfwSwapBuffers(window);
		glfwPollEvents();
	}

	writeln("Done.");
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

		glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * float.sizeof, cast(void*) 0);
		glEnableVertexAttribArray(0);
	
		glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * float.sizeof, cast(void*)(3 * float.sizeof));
		glEnableVertexAttribArray(1);
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

private void processInput(GLFWwindow* window)
{
	if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
	{
		glfwSetWindowShouldClose(window, true);
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
