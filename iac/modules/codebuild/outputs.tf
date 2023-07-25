output "build_name" {
  description = "The build name"
  value       = aws_codebuild_project.build.name
}