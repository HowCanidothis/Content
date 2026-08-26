const float M_PI = 3.14159265359;

bool fuzzyIsNull(float v)
{
    return abs(v) < 0.0000001;
}

bool fuzzyCompare(float v1, float v2)
{
    return abs(v2 - v1) < 0.0000001;
}
