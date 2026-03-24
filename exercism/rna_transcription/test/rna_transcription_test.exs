defmodule RnaTranscriptionTest do
  use ExUnit.Case, async: true
  doctest RnaTranscription

  describe "to_rna/1" do
    test "transcribes guanine to cytosine" do
      assert RnaTranscription.to_rna(~c"G") == ~c"C"
    end

    test "transcribes cytosine to guanine" do
      assert RnaTranscription.to_rna(~c"C") == ~c"G"
    end

    test "transcribes thymine to adenine" do
      assert RnaTranscription.to_rna(~c"T") == ~c"A"
    end

    test "transcribes adenine to uracil" do
      assert RnaTranscription.to_rna(~c"A") == ~c"U"
    end

    test "transcribes all nucleotides" do
      assert RnaTranscription.to_rna(~c"ACGTGGTCTTAA") == ~c"UGCACCAGAAUU"
    end
  end
end
