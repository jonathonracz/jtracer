//
//  JTDisBSDF.h
//  jtracer
//
//  Created by Jonathon Racz on 1/11/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#include <simd/simd.h>
using namespace simd;

namespace jt
{

// Based on the Disney microfacet model.
class DisBSDF
{
public:
    class Parameters
    {
    public:
        inline float3 getBaseColor() const { return baseColor; }
        inline void setBaseColor(float3 _baseColor) { baseColor = _baseColor; }

        inline float getSubsurface() const { return subsurface; }
        inline void setSubsurface(float _subsurface) { subsurface = _subsurface; }

        inline float getMetallic() const { return metallic; }
        inline void setMetallic(float _metallic) { metallic = _metallic; }

        inline float getSpecular() const { return specular; }
        inline void setSpecular(float _specular) { specular = _specular; calcIndexOfRefraction(); }

        inline float getSpecularTint() const { return specularTint; }
        inline void setSpecularTint(float _specularTint) { specularTint = _specularTint; }

        inline float getRoughness() const { return roughness; }
        inline void setRoughness(float _roughness) { roughness = _roughness; }

        inline float getAnisotropic() const { return anisotropic; }
        inline void setAnisotropic(float _anisotropic) { anisotropic = _anisotropic; }

        inline float getSheen() const { return sheen; }
        inline void setSheen(float _sheen) { sheen = _sheen; }

        inline float getSheenTint() const { return sheenTint; }
        inline void setSheenTint(float _sheenTint) { sheenTint = _sheenTint; }

        inline float getClearcoat() const { return clearcoat; }
        inline void setClearcoat(float _clearcoat) { clearcoat = _clearcoat; }

        inline float getClearcoatGloss() const { return clearcoatGloss; }
        inline void setClearcoatGloss(float _clearcoatGloss) { clearcoatGloss = _clearcoatGloss; }

        inline float getSpecTrans() const { return specTrans; }
        inline void setSpecTrans(float _specTrans) { specTrans = _specTrans; }

        inline float getScatterDistance() const { return scatterDistance; }
        inline void setScatterDistance(float _scatterDistance) { scatterDistance = _scatterDistance; }

    private:
        friend class DisBSDF;
        float3 baseColor;
        float subsurface;
        float metallic;
        float specular;
        float specularTint;
        float roughness;
        float anisotropic;
        float sheen;
        float sheenTint;
        float clearcoat;
        float clearcoatGloss;
        float specTrans;
        float scatterDistance;
        float indexOfRefraction;

        inline void calcIndexOfRefraction()
        {
            float fresnelAtNormalIncidence = 0.08f * specular;
            indexOfRefraction = 2.0f / (1.0f - sqrt(fresnelAtNormalIncidence));
        }
    };

    DisBSDF(JT_CONSTANT const Parameters& _params) :
        params(_params) {}

    float calcDisBSDF(float3 light, float3 view, float3 normal)
    {
        //simd::vec3 half = (light + view) /
        return 1.0f;
    }

private:
    JT_CONSTANT const Parameters& params;

    inline float indexOfRefractionEnteringMaterial(float fromIOR = 1.0f) const
    {
        return params.indexOfRefraction / fromIOR;
    }

    inline float indexOfRefractionExitingMaterial(float toIOR = 1.0f) const
    {
        return toIOR / params.indexOfRefraction;
    }

    float3 diffuse(float lightAngle, float viewAngle, float diffuseAngle) const
    {
        float fresnelLight = Math::power(1 - Math::cos(lightAngle), 5);
        float fresnelView = Math::power(1 - Math::cos(viewAngle), 5);
        float reflectionRoughness = 2.0f * params.roughness * Math::square(Math::cos(diffuseAngle));

        float3 fLambert = params.baseColor / Math::Constants::pi;
        float3 fRetroReflection = fLambert * reflectionRoughness * (fresnelLight + fresnelView + (fresnelLight * fresnelView * (reflectionRoughness - 1.0f)));
        float3 fDiffuse = (fLambert * (1.0f - (0.5f * fresnelLight)) * (1.0f - (0.5f * fresnelView))) + fRetroReflection;
        return fDiffuse;
    }

    float fresnel(float incidentAngle) const
    {
        float indexOfRefraction = indexOfRefractionEnteringMaterial(); // This will need to be figured out at some point
        float cosineThetaI = Math::cos(incidentAngle);
        float cosineThetaTSquared = (1.0f - ((1.0f - Math::square(cosineThetaI)) / Math::square(indexOfRefraction)));

        if (cosineThetaTSquared > 0)
        {
            float cosineThetaT = Math::sqrt(cosineThetaTSquared);
            float iorCosineThetaT = cosineThetaT * indexOfRefraction;
            float iorCosineThetaI = cosineThetaI * indexOfRefraction;

            float term1 = Math::square((cosineThetaI - iorCosineThetaT) / (cosineThetaI + iorCosineThetaT));
            float term2 = Math::square((cosineThetaT - iorCosineThetaI) / (cosineThetaT + iorCosineThetaI));
            float fresnel = (term1 + term2) / 2.0f;
            return fresnel;
        }

        return 1;
    }
};

}
