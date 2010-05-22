class String
  def end_with!(suffix)
    end_with?(suffix) ? self : self << suffix
  end
end
