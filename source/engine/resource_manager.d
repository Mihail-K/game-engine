module engine.resource_manager;

import engine.shader;
import engine.texture;

struct ResourceManager
{
private:
    Shader[string]  _shaderCache;
    Texture[string] _textureCache;

public:
    Shader createShader(string key, in ShaderConfig[] shaderConfigs...)
    {
        return _shaderCache[key] = Shader(shaderConfigs);
    }

    Shader fetchShader(string key)
    {
        return _shaderCache[key];
    }

    bool removeShader(string key)
    {
        return _shaderCache.remove(key);
    }

    Texture createTexture(string key, string filename, TextureConfig config = TextureConfig.init)
    {
        Texture texture = Texture(config);

        texture.load(filename);

        return _textureCache[key] = texture;
    }

    Texture fetchTexture(string key)
    {
        return _textureCache[key];
    }

    bool removeTexture(string key)
    {
        return _textureCache.remove(key);
    }

    void clear()
    {
        _shaderCache.clear();
        _textureCache.clear();
    }
}
