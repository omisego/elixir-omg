# Copyright 2019 OmiseGO Pte Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

defmodule OMG.Utils.Metrics do
  @moduledoc """
  In option can discard some metrics trigger.
  ## Example

      config :metrics,
        discard: [:State]
  """

  use Appsignal.Instrumentation.Decorators

  use Decorator.Define,
    measure_start: 0,
    measure_event: 0

  @discard_namespace_metrics Application.get_env(:metrics, :discard, [])

  def measure_start(body, context) do
    namespace = context.module |> Module.split() |> List.last() |> String.to_existing_atom()

    if Enum.find(@discard_namespace_metrics, &match?(^&1, namespace)),
      do: body,
      else: Appsignal.Instrumentation.Decorators.transaction(namespace, body, context)
  end

  def measure_event(body, context) do
    namespace = context.module |> Module.split() |> List.last() |> String.to_existing_atom()

    if Enum.find(@discard_namespace_metrics, &match?(^&1, namespace)),
      do: body,
      else: Appsignal.Instrumentation.Decorators.transaction_event(namespace, body, context)
  end
end
