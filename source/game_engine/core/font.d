module game_engine.core.font;

import bindbc.freetype;
import bindbc.opengl;

import game_engine.utils.vector;

struct FontConfig
{
    string path;
    uint   width  = 0;
    uint   height = 48;
}

struct FontCharacter
{
    uint  textureID;
    IVec2 size;
    IVec2 bearing;
    uint  advance;
}

class Font
{
private:
    FT_Library          _ft;
    FT_Face             _face;
    FontCharacter[char] _cache;

public:
    this(FontConfig config)
    {
        import std.string : toStringz;

        assert(!FT_Init_FreeType(&_ft), "Failed to initialize FreeType Library.");
        assert(!FT_New_Face(_ft, config.path.toStringz, 0, &_face), "Failed to create Font Face.");

        FT_Set_Pixel_Sizes(_face, config.width, config.height);
    }

    ~this()
    {
        FT_Done_Face(_face);
        FT_Done_FreeType(_ft);
    }

    bool loaded(char ch)
    {
        return !!(ch in _cache);
    }

    void loadChar(char ch)
    {
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

        assert(!FT_Load_Char(_face, ch, FT_LOAD_RENDER), "Failed to load Glyph.");

        FontCharacter fontChar;

        glGenTextures(1, &fontChar.textureID);
        glBindTexture(GL_TEXTURE_2D, fontChar.textureID);

        glTexImage2D(
            GL_TEXTURE_2D,
            0,
            GL_RED,
            _face.glyph.bitmap.width,
            _face.glyph.bitmap.rows,
            0,
            GL_RED,
            GL_UNSIGNED_BYTE,
            _face.glyph.bitmap.buffer
        );

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

        fontChar.size    = IVec2(_face.glyph.bitmap.width, _face.glyph.bitmap.rows);
        fontChar.bearing = IVec2(_face.glyph.bitmap_left,  _face.glyph.bitmap_top);
        fontChar.advance = _face.glyph.advance.x;

        _cache[ch] = fontChar;

        glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
    }

    FontCharacter getChar(char ch)
    {
        return _cache[ch];
    }
}
