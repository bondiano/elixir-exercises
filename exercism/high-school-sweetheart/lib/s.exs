# Задание
# Реализуем шифр Цезаря -- простой способ шифрования путем сдвига каждого символа на константу.

# Нужно реализовать функцию encode/2, которая принимает строку и сдвиг, и возвращает зашифрованную строку.

# Solution.encode('Hello', 10)
# # => 'Rovvy'
# Solution.encode('Hello', 5)
# # => 'Mjqqt'
# Также нужно реализовать функцию decode/2, которая принимает зашифрованную строку и сдвиг, и возвращает оригинальную строку.

# Solution.decode('Rovvy', 10)
# # => 'Hello'
# Solution.decode('Mjqqt', 5)
# # => 'Hello'

defmodule Solution do
  # BEGIN (write your solution here)
  def encode(str, shift) do
    Enum.map(str, &(&1 + shift))
  end

  def decode(str, shift) do
    Enum.map(str, &(&1 - shift))
  end

  # END
end

ExUnit.start()

defmodule Test do
  use ExUnit.Case
  import Solution

  test "encode/decode" do
    assert encode(~c"Hello", 10) |> decode(10) == ~c"Hello"
    assert encode(~c"12345", 1) == ~c"23456"
    assert decode(~c"12345", 1) == ~c"01234"
    assert encode(~c"abcdef", 2) == ~c"cdefgh"
    assert decode(~c"abcdef", 2) == ~c"_`abcd"
  end

  test "encode/decode with cyrillic symbols" do
    assert encode(~c"Привет", 10) |> decode(10) == ~c"Привет"
    assert encode(~c"Привет мир", 500) |> decode(500) == ~c"Привет мир"
  end
end
