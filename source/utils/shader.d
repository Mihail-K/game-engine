module utils.shader;

import bindbc.opengl;

import std.string;

struct ShaderConfig
{
	string source;
	uint   type;
}

struct Shader
{
private:
	uint _programID;

public:
	this(in ShaderConfig[] configs...)
	{
		_programID = createShaderProgram(configs);
	}

	void use()
	{
		glUseProgram(_programID);
	}

    int uniformLocation(string name)
    {
        return glGetUniformLocation(_programID, name.toStringz);
    }
}

private uint createShaderProgram(in ShaderConfig[] shaderConfigs...)
{
	import std.array : array;
	import std.algorithm : map;

	uint[] shaders = shaderConfigs
		.map!((shaderConfig) => compileShader(shaderConfig.source, shaderConfig.type))
		.array;

	scope (exit)
	{
		foreach (shader; shaders)
		{
			glDeleteShader(shader);
		}
	}

	return linkShaders(shaders);
}

private uint linkShaders(uint[] shaders...)
{
	uint program = glCreateProgram();

	foreach (shader; shaders)
	{
		glAttachShader(program, shader);
	}

	glLinkProgram(program);

	int success;
	glGetProgramiv(program, GL_LINK_STATUS, &success);

	if (!success)
	{
		auto infoLog = new char[512];
		glGetProgramInfoLog(program, cast(uint) infoLog.length, null, infoLog.ptr);

		assert(0, infoLog.ptr.fromStringz);
	}

	return program;
}

private uint compileShader(string source, uint type)
{
	uint shader  = glCreateShader(type);
	auto sources = [cast(char*) source.ptr];
	auto lengths = [cast(int) source.length];

	glShaderSource(shader, 1, sources.ptr, lengths.ptr);
	glCompileShader(shader);

	int success;
	glGetShaderiv(shader, GL_COMPILE_STATUS, &success);

	if (!success)
	{
		auto infoLog = new char[512];
		glGetShaderInfoLog(shader, cast(uint) infoLog.length, null, infoLog.ptr);

		assert(0, infoLog.ptr.fromStringz);
	}

	return shader;
}
