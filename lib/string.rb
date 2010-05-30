class String
  def end_with!(suffix)
    end_with?(suffix) ? self : self << suffix
  end

  def unindent
    sub(/\A#{InteractiveFiction::Parser::INDENT}/, '')
  end
end
