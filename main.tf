module "label" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=0.1.3"
  attributes = "${var.attributes}"
  delimiter  = "${var.delimiter}"
  name       = "${var.name}"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  tags       = "${var.tags}"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["${var.aws_principal_service}.amazonaws.com"]
    }
  }

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["${var.assume_role_arns}"]
    }
  }
}

data "aws_iam_policy_document" "default" {
  statement {
    actions   = ["ssm:DescribeParameters"]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions   = ["${var.ssm_actions}"]
    resources = ["${formatlist("arn:aws:ssm:%s:%s:parameter/%s", var.region, var.account_id, var.ssm_parameters)}"]
    effect    = "Allow"
  }

  statement {
    actions   = ["kms:Decrypt"]
    resources = ["${var.kms_key_arn}"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "default" {
  name        = "${module.label.id}"
  description = "Allow SSM actions"
  policy      = "${data.aws_iam_policy_document.default.json}"
}

resource "aws_iam_role" "default" {
  name                 = "${module.label.id}"
  assume_role_policy   = "${data.aws_iam_policy_document.assume_role.json}"
  description          = "IAM Role with permissions to perform actions on SSM resources"
  max_session_duration = "${var.max_session_duration}"
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = "${aws_iam_role.default.name}"
  policy_arn = "${aws_iam_policy.default.arn}"
}

resource "aws_iam_role_policy_attachment" "amazon_ecs_task_execution_role_policy_attach" {
  count                                             = "${var.aws_principal_service == 'ecs-tasks' ? 1 : 0}"
  role       = "${aws_iam_role.default.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
