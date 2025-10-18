package terratest

import (
    "path/filepath"
    "testing"
    tg "github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformValidate(t *testing.T) {
    opts := &tg.Options{
        TerraformDir: filepath.Join("..", "..", "infra", "terraform"),
        NoColor:      true,
        BackendConfig: map[string]interface{}{},
    }
    tg.Init(t, opts)
    tg.Validate(t, opts)
}

