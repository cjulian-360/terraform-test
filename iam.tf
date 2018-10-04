data "template_file" "assume_role_policy" {
  template = "${file("./assume_role_policy.tpl")}"
}

resource "aws_iam_role" "service_role" {
  name = "orca-test-role"
  assume_role_policy = "${data.template_file.assume_role_policy.rendered}"
}

resource "aws_iam_instance_profile" "service_instance_profile" {
  name = "orca-test-instance-profile"
  role = "${aws_iam_role.service_role.name}"
}
