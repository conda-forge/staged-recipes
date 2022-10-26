//
// Created by Kez Cleal on 26/07/2022.
//

#include <cstring>
#include <string>
#include <GLFW/glfw3.h>
//#include <unordered_map>
#include "../include/robin_hood.h"

namespace Keys {

    void getKeyTable(robin_hood::unordered_map<std::string, int>& kt) {
        kt["SPACE"] = GLFW_KEY_SPACE;
        kt["APOSTROPHE"] = GLFW_KEY_APOSTROPHE;
        kt["COMMA"] = GLFW_KEY_COMMA;
        kt["MINUS"] = GLFW_KEY_MINUS;
        kt["PERIOD"] = GLFW_KEY_PERIOD;
        kt["SLASH"] = GLFW_KEY_SLASH;
        kt["0"] = GLFW_KEY_0;
        kt["1"] = GLFW_KEY_1;
        kt["2"] = GLFW_KEY_2;
        kt["3"] = GLFW_KEY_3;
        kt["4"] = GLFW_KEY_4;
        kt["5"] = GLFW_KEY_5;
        kt["6"] = GLFW_KEY_6;
        kt["7"] = GLFW_KEY_7;
        kt["8"] = GLFW_KEY_8;
        kt["9"] = GLFW_KEY_9;
        kt["SEMICOLON"] = GLFW_KEY_SEMICOLON;
        kt["EQUAL"] = GLFW_KEY_EQUAL;
        kt["A"] = GLFW_KEY_A;
        kt["B"] = GLFW_KEY_B;
        kt["C"] = GLFW_KEY_C;
        kt["D"] = GLFW_KEY_D;
        kt["E"] = GLFW_KEY_E;
        kt["F"] = GLFW_KEY_F;
        kt["G"] = GLFW_KEY_G;
        kt["H"] = GLFW_KEY_H;
        kt["I"] = GLFW_KEY_I;
        kt["J"] = GLFW_KEY_J;
        kt["K"] = GLFW_KEY_K;
        kt["L"] = GLFW_KEY_L;
        kt["M"] = GLFW_KEY_M;
        kt["N"] = GLFW_KEY_N;
        kt["O"] = GLFW_KEY_O;
        kt["P"] = GLFW_KEY_P;
        kt["Q"] = GLFW_KEY_Q;
        kt["R"] = GLFW_KEY_R;
        kt["S"] = GLFW_KEY_S;
        kt["T"] = GLFW_KEY_T;
        kt["U"] = GLFW_KEY_U;
        kt["V"] = GLFW_KEY_V;
        kt["W"] = GLFW_KEY_W;
        kt["X"] = GLFW_KEY_X;
        kt["Y"] = GLFW_KEY_Y;
        kt["Z"] = GLFW_KEY_Z;
        kt["LEFT_BRACKET"] = GLFW_KEY_LEFT_BRACKET;
        kt["BACKSLASH"] = GLFW_KEY_BACKSLASH;
        kt["RIGHT_BRACKET"] = GLFW_KEY_RIGHT_BRACKET;
        kt["GRAVE_ACCENT"] = GLFW_KEY_GRAVE_ACCENT;
        kt["WORLD_1"] = GLFW_KEY_WORLD_1;
        kt["WORLD_2"] = GLFW_KEY_WORLD_2;
        kt["ESCAPE"] = GLFW_KEY_ESCAPE;
        kt["ENTER"] = GLFW_KEY_ENTER;
        kt["TAB"] = GLFW_KEY_TAB;
        kt["BACKSPACE"] = GLFW_KEY_BACKSPACE;
        kt["INSERT"] = GLFW_KEY_INSERT;
        kt["DELETE"] = GLFW_KEY_DELETE;
        kt["RIGHT"] = GLFW_KEY_RIGHT;
        kt["LEFT"] = GLFW_KEY_LEFT;
        kt["DOWN"] = GLFW_KEY_DOWN;
        kt["UP"] = GLFW_KEY_UP;
        kt["PAGE_UP"] = GLFW_KEY_PAGE_UP;
        kt["PAGE_DOWN"] = GLFW_KEY_PAGE_DOWN;
        kt["HOME"] = GLFW_KEY_HOME;
        kt["END"] = GLFW_KEY_END;
        kt["CAPS_LOCK"] = GLFW_KEY_CAPS_LOCK;
        kt["SCROLL_LOCK"] = GLFW_KEY_SCROLL_LOCK;
        kt["NUM_LOCK"] = GLFW_KEY_NUM_LOCK;
        kt["PRINT_SCREEN"] = GLFW_KEY_PRINT_SCREEN;
        kt["PAUSE"] = GLFW_KEY_PAUSE;
        kt["F1"] = GLFW_KEY_F1;
        kt["F2"] = GLFW_KEY_F2;
        kt["F3"] = GLFW_KEY_F3;
        kt["F4"] = GLFW_KEY_F4;
        kt["F5"] = GLFW_KEY_F5;
        kt["F6"] = GLFW_KEY_F6;
        kt["F7"] = GLFW_KEY_F7;
        kt["F8"] = GLFW_KEY_F8;
        kt["F9"] = GLFW_KEY_F9;
        kt["F10"] = GLFW_KEY_F10;
        kt["F11"] = GLFW_KEY_F11;
        kt["F12"] = GLFW_KEY_F12;
        kt["F13"] = GLFW_KEY_F13;
        kt["F14"] = GLFW_KEY_F14;
        kt["F15"] = GLFW_KEY_F15;
        kt["F16"] = GLFW_KEY_F16;
        kt["F17"] = GLFW_KEY_F17;
        kt["F18"] = GLFW_KEY_F18;
        kt["F19"] = GLFW_KEY_F19;
        kt["F20"] = GLFW_KEY_F20;
        kt["F21"] = GLFW_KEY_F21;
        kt["F22"] = GLFW_KEY_F22;
        kt["F23"] = GLFW_KEY_F23;
        kt["F24"] = GLFW_KEY_F24;
        kt["F25"] = GLFW_KEY_F25;
        kt["KP_0"] = GLFW_KEY_KP_0;
        kt["KP_1"] = GLFW_KEY_KP_1;
        kt["KP_2"] = GLFW_KEY_KP_2;
        kt["KP_3"] = GLFW_KEY_KP_3;
        kt["KP_4"] = GLFW_KEY_KP_4;
        kt["KP_5"] = GLFW_KEY_KP_5;
        kt["KP_6"] = GLFW_KEY_KP_6;
        kt["KP_7"] = GLFW_KEY_KP_7;
        kt["KP_8"] = GLFW_KEY_KP_8;
        kt["KP_9"] = GLFW_KEY_KP_9;
        kt["KP_DECIMAL"] = GLFW_KEY_KP_DECIMAL;
        kt["KP_DIVIDE"] = GLFW_KEY_KP_DIVIDE;
        kt["KP_MULTIPLY"] = GLFW_KEY_KP_MULTIPLY;
        kt["KP_SUBTRACT"] = GLFW_KEY_KP_SUBTRACT;
        kt["KP_ADD"] = GLFW_KEY_KP_ADD;
        kt["KP_ENTER"] = GLFW_KEY_KP_ENTER;
        kt["KP_EQUAL"] = GLFW_KEY_KP_EQUAL;
        kt["LEFT_SHIFT"] = GLFW_KEY_LEFT_SHIFT;
        kt["LEFT_CONTROL"] = GLFW_KEY_LEFT_CONTROL;
        kt["LEFT_ALT"] = GLFW_KEY_LEFT_ALT;
        kt["LEFT_SUPER"] = GLFW_KEY_LEFT_SUPER;
        kt["RIGHT_SHIFT"] = GLFW_KEY_RIGHT_SHIFT;
        kt["RIGHT_CONTROL"] = GLFW_KEY_RIGHT_CONTROL;
        kt["RIGHT_ALT"] = GLFW_KEY_RIGHT_ALT;
        kt["RIGHT_SUPER"] = GLFW_KEY_RIGHT_SUPER;
        kt["MENU"] = GLFW_KEY_MENU;
    };

}
