locals {
  enable_s3_to_fsx_seed = var.s3_seed_bucket_name != ""
  s3_seed_subdirectory  = var.s3_seed_prefix == "" ? null : "/${trim(var.s3_seed_prefix, "/")}"
  fsx_seed_subdirectory = var.fsx_seed_subdirectory == "" ? null : "/${trim(var.fsx_seed_subdirectory, "/")}"
  s3_seed_bucket_arn    = "arn:aws:s3:::${var.s3_seed_bucket_name}"
  s3_seed_objects_arn   = var.s3_seed_prefix == "" ? "${local.s3_seed_bucket_arn}/*" : "${local.s3_seed_bucket_arn}/${trim(var.s3_seed_prefix, "/")}/*"
}

data "aws_iam_policy_document" "datasync_assume_role" {
  count = local.enable_s3_to_fsx_seed ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["datasync.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "datasync_s3_access" {
  count = local.enable_s3_to_fsx_seed ? 1 : 0

  name               = "${var.name}-datasync-s3-access"
  assume_role_policy = data.aws_iam_policy_document.datasync_assume_role[0].json
  tags               = var.tags
}

data "aws_iam_policy_document" "datasync_s3_access" {
  count = local.enable_s3_to_fsx_seed ? 1 : 0

  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]

    resources = [local.s3_seed_bucket_arn]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionTagging"
    ]

    resources = [local.s3_seed_objects_arn]
  }
}

resource "aws_iam_role_policy" "datasync_s3_access" {
  count = local.enable_s3_to_fsx_seed ? 1 : 0

  name   = "${var.name}-datasync-s3-access"
  role   = aws_iam_role.datasync_s3_access[0].id
  policy = data.aws_iam_policy_document.datasync_s3_access[0].json
}

resource "aws_datasync_location_s3" "seed_source" {
  count = local.enable_s3_to_fsx_seed ? 1 : 0

  s3_bucket_arn = local.s3_seed_bucket_arn
  subdirectory  = local.s3_seed_subdirectory != null ? local.s3_seed_subdirectory : "/"

  s3_config {
    bucket_access_role_arn = aws_iam_role.datasync_s3_access[0].arn
  }

  tags = var.tags
}

resource "aws_datasync_location_fsx_windows_file_system" "seed_destination" {
  count = local.enable_s3_to_fsx_seed ? 1 : 0

  fsx_filesystem_arn = module.fsx.arn
  security_group_arns = [
    module.fsx.security_group_arn
  ]
  user         = "Admin"
  password     = local.ad_admin_password
  domain       = local.ad_domain
  subdirectory = local.fsx_seed_subdirectory

  tags = var.tags
}

resource "aws_datasync_task" "s3_to_fsx" {
  count = local.enable_s3_to_fsx_seed ? 1 : 0

  name                     = "${var.name}-s3-to-fsx-seed"
  source_location_arn      = aws_datasync_location_s3.seed_source[0].arn
  destination_location_arn = aws_datasync_location_fsx_windows_file_system.seed_destination[0].arn

  options {
    atime                          = "BEST_EFFORT"
    bytes_per_second               = -1
    gid                            = "NONE"
    log_level                      = "OFF"
    overwrite_mode                 = "ALWAYS"
    posix_permissions              = "NONE"
    preserve_deleted_files         = "PRESERVE"
    preserve_devices               = "NONE"
    security_descriptor_copy_flags = "OWNER_DACL"
    task_queueing                  = "ENABLED"
    transfer_mode                  = "CHANGED"
    uid                            = "NONE"
    verify_mode                    = "POINT_IN_TIME_CONSISTENT"
  }

  tags = var.tags
}
