defmodule Credo.Check.Warning.ComplexElseClausesInWith do
  use Credo.Check,
    base_priority: :high,
    category: :warning,
    explanations: [
      check: """
      Extracting CEC (total clause count in the else block of a `with`)
      for every with...else found in a function.
      """
    ]

  @impl Credo.Check
  def run(%SourceFile{} = source_file, params) do
    issue_meta = IssueMeta.for(source_file, params)

    Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta))
  end

  defp traverse({def_op, meta, [head | _]} = ast, issues, issue_meta)
      when def_op in [:def, :defp] do
    fun_name = get_function_name(head)

    with_nodes = find_with_else_nodes(ast)

    if Enum.any?(with_nodes, fn {_, cec} -> cec > 4 end) do
      with_issues =
        Enum.map(with_nodes, fn {with_meta, cec} ->
          issue_for(issue_meta, with_meta[:line] || meta[:line], fun_name, cec)
        end)

      {ast, with_issues ++ issues}
    else
      {ast, issues}
    end
  end

  defp traverse(ast, issues, _), do: {ast, issues}

  defp find_with_else_nodes(ast) do
    {_, results} =
      Macro.prewalk(ast, [], fn
        {:with, with_meta, args} = node, acc when is_list(args) ->
          case find_else_clauses(args) do
            nil -> {node, acc}
            else_clauses -> {node, [{with_meta, length(else_clauses)} | acc]}
          end

        node, acc ->
          {node, acc}
      end)

    Enum.reverse(results)
  end

  defp find_else_clauses(args) do
    case List.last(args) do
      opts when is_list(opts) ->
        case Keyword.get(opts, :else) do
          clauses when is_list(clauses) -> clauses
          _ -> nil
        end

      _ ->
        nil
    end
  end

  defp get_function_name({:when, _, [name_and_args | _]}), do: get_function_name(name_and_args)
  defp get_function_name({name, _, _}) when is_atom(name), do: to_string(name)
  defp get_function_name(_), do: "funcao_dinamica"

  defp issue_for(issue_meta, line_no, trigger, cec) do
    format_issue(
      issue_meta,
      message: "CEC=#{cec}",
      trigger: trigger,
      line_no: line_no
    )
  end
end
