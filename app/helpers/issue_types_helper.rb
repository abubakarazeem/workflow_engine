module IssueTypesHelper
  def issue_type_table_row_id(issue_type)
    "issue_type_#{issue_type.id}"
  end

  def issue_type_table_row_class(issue_type)
    issue_type.project_id.nil? ? 'global' : "project-#{issue_type.project_id}"
  end

  def issue_type_project_number(issue_type)
    issue_type.project_id.nil? ? 'NA' : issue_type.project_id.to_s
  end
end