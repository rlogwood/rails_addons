# frozen_string_literal: true

module BlogHelper

  # format markdown if present, sanitize, add emojis and do syntax highlighting
  # add html-pipeline gem and required dependencies to use this
  # TODO: figure out a workaround to the hack of testing for empty result after applying markdown filter
  def html_pipeline(content)

    # TODO: is this hack really necessary?
    result = html_pipeline_with_markdown(content)
    #result = html_pipeline_without_markdown(content) if result.blank? || result =~ /\A\s*\Z/
    result.html_safe
  end

  private

  PIPELINE_CONTEXT = {
    gfm: true,
    asset_root: 'https://assets-cdn.github.com/images/icons/emoji/unicode'
  }.freeze

  def html_pipeline_with_markdown(content)
    pipeline = HTML::Pipeline.new [
                                    HTML::Pipeline::MarkdownFilter,
                                    HTML::Pipeline::SanitizationFilter,
                                    HTML::Pipeline::ImageMaxWidthFilter,
                                    HTML::Pipeline::EmojiFilter,
                                    HTML::Pipeline::SyntaxHighlightFilter,
                                    HTML::Pipeline::AutolinkFilter
                                  ], PIPELINE_CONTEXT
    pipeline.call(content)[:output].to_s
  end

  def html_pipeline_without_markdown(content)
    pipeline = HTML::Pipeline.new [
                                    HTML::Pipeline::SanitizationFilter,
                                    HTML::Pipeline::ImageMaxWidthFilter,
                                    HTML::Pipeline::EmojiFilter,
                                    HTML::Pipeline::SyntaxHighlightFilter,
                                  # HTML::Pipeline::AutolinkFilter
                                  ], PIPELINE_CONTEXT
    pipeline.call(content)[:output]
  end

end