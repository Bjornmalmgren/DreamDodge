class APlatform : AActor{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;
    UPROPERTY(DefaultComponent)
    UStaticMeshComponent Mesh;
    UPROPERTY()
    EDimension ExistingDimension;

    UMaterialInstanceDynamic DynamicMaterial;

    UFUNCTION()
    void SetColor(FLinearColor Color){
        DynamicMaterial = Mesh.CreateDynamicMaterialInstance(0);
        DynamicMaterial.SetVectorParameterValue(n"Color", Color);
    }
}