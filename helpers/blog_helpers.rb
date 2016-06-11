module BlogHelpers
  def formatted_date
    format_date(current_article)
  end

  def format_date(post)
    post.date.strftime("%B %e, %Y")
  end
end
