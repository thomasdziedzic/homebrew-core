class Camlp5TransitionalModeRequirement < Requirement
  fatal true

  satisfy(:build_env => false) { !Tab.for_name("camlp5").with?("strict") }

  def message; <<-EOS.undent
    camlp5 must be compiled in transitional mode (instead of --strict mode):
      brew install camlp5
    EOS
  end
end

class Coq < Formula
  desc "Proof assistant for higher-order logic"
  homepage "https://coq.inria.fr/"
  url "https://coq.inria.fr/distrib/8.5pl1/files/coq-8.5pl1.tar.gz"
  version "8.5pl1_1"
  sha256 "4bfa75b10ae1be61301d0f7bc087b7c24e0b8bd025dd358c75709ac04ddd5df0"

  head "git://scm.gforge.inria.fr/coq/coq.git", :branch => "trunk"

  bottle do
    sha256 "e706d2948ccd15a6e18457eb67bb63d8d53455f7c1f990a204009e1047a1bbbf" => :el_capitan
    sha256 "4e8fde277f24161668a9de85d257b86b70d3cf865f4ba12763830ef0d5e95e29" => :yosemite
    sha256 "3991916a01a65169945183ad301995080da96e52869e539f051d66b93c3969bf" => :mavericks
  end

  depends_on Camlp5TransitionalModeRequirement
  depends_on "camlp5"
  depends_on "ocaml"
  depends_on "lablgtk"

  def install
    camlp5_lib = Formula["camlp5"].opt_lib+"ocaml/camlp5"
    system "./configure", "-prefix", prefix,
                          "-mandir", man,
                          "-camlp5dir", camlp5_lib,
                          "-emacslib", "#{share}/emacs/site-lisp/coq",
                          "-coqdocdir", "#{pkgshare}/latex",
                          "-coqide", "opt",
                          "-with-doc", "no"
    ENV.j1 # Otherwise "mkdir bin" can be attempted by more than one job
    system "make", "world"
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    To use the Coq Emacs mode, add the following to your init file:
      (setq auto-mode-alist (cons '("\\\\.v$" . coq-mode) auto-mode-alist))
      (autoload 'coq-mode "coq" "Major mode for editing Coq vernacular." t)
    EOS
  end

  test do
    (testpath/"testing.v").write <<-EOS.undent
      Inductive nat : Set :=
      | O : nat
      | S : nat -> nat.
      Fixpoint add (n m: nat) : nat :=
        match n with
        | O => m
        | S n' => S (add n' m)
        end.
      Lemma add_O_r : forall (n: nat), add n O = n.
      intros n; induction n; simpl; auto; rewrite IHn; auto.
      Qed.
    EOS
    system("#{bin}/coqc", "#{testpath}/testing.v")
  end
end
