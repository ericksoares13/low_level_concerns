defmodule Credo.Check.Warning.ComplexBranching do
  use Credo.Check,
    base_priority: :high,
    category: :warning,
    explanations: [
      check: """
      Extracting values of LOC and CC from a function.
      """
    ]

  alias Credo.Check.Refactor.CyclomaticComplexity
  alias Credo.SourceFile

  @loc_threshold 33
  @cc_threshold 8

  @impl Credo.Check
  def run(%SourceFile{} = source_file, params) do
    issue_meta = IssueMeta.for(source_file, params)
    lines = SourceFile.lines(source_file)

    Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta, lines))
  end

  defp traverse({def_op, meta, [head | _]} = ast, issues, issue_meta, lines)
       when def_op in [:def, :defp] do
    fun_name = get_function_name(head)
    line_no = meta[:line]

    cc = CyclomaticComplexity.complexity_for(ast)
    loc = count_loc(ast, lines)

    if loc >= @loc_threshold && cc >= @cc_threshold do
      {ast, [issue_for(issue_meta, line_no, fun_name, loc, cc) | issues]}
    else
      {ast, issues}
    end
  end

  defp traverse(ast, issues, _, _), do: {ast, issues}

  defp count_loc({_def_op, meta, _} = ast, lines) do
    first_line = meta[:line] || 0

    last_line =
      Macro.prewalk(ast, 0, fn
        {_, node_meta, _} = node, max ->
          line = (node_meta[:line]) || 0
          {node, max(line, max)}
        node, max ->
          {node, max}
      end)
      |> elem(1)

    lines
    |> Enum.filter(fn {line_no, line} ->
      line_no >= first_line and
      line_no <= last_line and
      String.trim(line) != "" and
      not String.starts_with?(String.trim(line), "#")
    end)
    |> length()
  end

  defp get_function_name({:when, _, [name_and_args | _]}), do: get_function_name(name_and_args)
  defp get_function_name({name, _, _}) when is_atom(name), do: to_string(name)
  defp get_function_name(_), do: "funcao_dinamica"

  defp issue_for(issue_meta, line_no, trigger, loc, cc) do
    format_issue(
      issue_meta,
      message: "LOC=#{loc};CC=#{cc}",
      trigger: trigger,
      line_no: line_no
    )
  end
end
