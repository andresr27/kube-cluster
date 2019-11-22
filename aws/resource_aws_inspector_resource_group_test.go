package aws

import (
	"fmt"
	"testing"

	"github.com/hashicorp/terraform-plugin-sdk/helper/resource"
	"github.com/hashicorp/terraform-plugin-sdk/terraform"
)

func TestAccAWSInspectorResourceGroup_basic(t *testing.T) {
	resource.ParallelTest(t, resource.TestCase{
		PreCheck:     func() { testAccPreCheck(t) },
		Providers:    testAccProviders,
		CheckDestroy: nil,
		Steps: []resource.TestStep{
			{
				Config: testAccAWSInspectorResourceGroup,
				Check: resource.ComposeTestCheckFunc(
					testAccCheckAWSInspectorResourceGroupExists("aws_inspector_resource_group.foo"),
				),
			},
			{
				Config: testAccCheckAWSInspectorResourceGroupModified,
				Check: resource.ComposeTestCheckFunc(
					testAccCheckAWSInspectorResourceGroupExists("aws_inspector_resource_group.foo"),
				),
			},
		},
	})
}

func testAccCheckAWSInspectorResourceGroupExists(name string) resource.TestCheckFunc {
	return func(s *terraform.State) error {
		_, ok := s.RootModule().Resources[name]
		if !ok {
			return fmt.Errorf("Not found: %s", name)
		}

		return nil
	}
}

var testAccAWSInspectorResourceGroup = `
resource "aws_inspector_resource_group" "foo" {
	tags = {
	  Name  = "foo"
  }
}`

var testAccCheckAWSInspectorResourceGroupModified = `
resource "aws_inspector_resource_group" "foo" {
	tags = {
	  Name  = "bar"
  }
}`