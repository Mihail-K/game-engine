module game_engine.core.shader;

import bindbc.opengl;

import std.string;

import game_engine.utils.matrix;
import game_engine.utils.vector;

struct ShaderConfig
{
	string code;
	uint   type;
}

struct Shader
{
private:
	uint _programID;

public:
	@disable this();

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

    void setInt(string name, int value)
    {
        glUniform1i(uniformLocation(name), value);
    }

    void setFloat(string name, float value)
    {
        glUniform1f(uniformLocation(name), value);
    }

	void setVector3(string name, Vec3 value)
	{
		glUniform3f(uniformLocation(name), value.x, value.y, value.z);
	}

	void setMatrix4(string name, Mat4 value)
	{
		glUniformMatrix4fv(uniformLocation(name), 1, true, value.ptr);
	}
}

private uint createShaderProgram(in ShaderConfig[] configs...)
{
	import std.array : array;
	import std.algorithm : map;

	uint[] shaders = configs
		.map!(compileShader)
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

private uint compileShader(ShaderConfig config)
{
	uint shader  = glCreateShader(config.type);
	auto sources = [cast(char*) config.code.ptr];
	auto lengths = [cast(int) config.code.length];

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

private byte[] loadShaderFile(string filename)
{
	import std.stdio : File;

    auto file = File(filename, "rb");

    file.seek(0, SEEK_END);

    byte[] output = new byte[file.tell];

    file.seek(0, SEEK_SET);
    file.rawRead(output);
    file.close();

    return output;
}
