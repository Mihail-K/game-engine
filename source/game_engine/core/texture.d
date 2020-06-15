module game_engine.core.texture;

import bindbc.opengl;

import imagefmt;

struct TextureAsset
{
private:
    IFImage _image;

public:
    @property
    ubyte[] data()
    {
        return _image.buf8;
    }

    @property
    uint width()
    {
        return _image.w;
    }

    @property
    uint height()
    {
        return _image.h;
    }

    @property
    uint format()
    {
        import std.string : format;

        switch (_image.c)
        {
            case 1:
                return GL_R8;

            case 2:
                return GL_RG;

            case 3:
                return GL_RGB;

            case 4:
                return GL_RGBA;

            default:
                assert(0, "Unsupported Image Format (%d channels).".format(_image.c));
        }
    }

    void release()
    {
        _image.free();
    }
}

struct TextureConfig
{
    uint internalFormat = GL_RGB;
    uint wrapS          = GL_REPEAT;
    uint wrapT          = GL_REPEAT;
    uint filterMin      = GL_LINEAR;
    uint filterMax      = GL_LINEAR;
}

struct Texture
{
private:
    uint _textureID;
    uint _width;
    uint _height;
    uint _imageFormat;
    uint _internalFormat;
    uint _wrapS;
    uint _wrapT;
    uint _filterMin;
    uint _filterMax;

public:
    @disable this();

    this(TextureConfig config)
    {
        glGenTextures(1, &_textureID);

        _internalFormat = config.internalFormat;
        _wrapS          = config.wrapS;
        _wrapT          = config.wrapT;
        _filterMin      = config.filterMin;
        _filterMax      = config.filterMax;
    }

    void load(string filename)
    {
        auto asset = loadTextureAsset(filename);
        scope (exit) asset.release();

        load(asset);
    }

    void load(TextureAsset asset)
    {
        _width       = asset.width;
        _height      = asset.height;
        _imageFormat = asset.format;

        bind();

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, _wrapS);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, _wrapT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, _filterMin);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, _filterMax);

        glTexImage2D(GL_TEXTURE_2D, 0, _internalFormat, _width, _height, 0, _imageFormat, GL_UNSIGNED_BYTE, asset.data.ptr);
        glGenerateMipmap(GL_TEXTURE_2D);

        unbind();
    }

    void bind()
    {
        glBindTexture(GL_TEXTURE_2D, _textureID);
    }

    void unbind()
    {
        glBindTexture(GL_TEXTURE_2D, 0);
    }
}

TextureAsset loadTextureAsset(string filename)
{
    auto image = read_image(filename);
	assert(!image.e, "Failed to load Image Asset");

    return TextureAsset(image);
}
