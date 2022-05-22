package datatypes;

import java.util.*;
import java.util.function.BiFunction;
import java.util.function.Function;
import java.util.function.Predicate;

import org.rascalmpl.ast.Assoc.Left;

public class FStream<T>{
    public Function<Object, Step> stepper; // the stepper function: (s -> Step a s)
    public Object state; // the stream's state

    public FStream(Function<Object, Step> stepper, Object state){
        this.stepper = stepper;
        this.state = state;
    }

    public Function<Object, Step> getStepper() {
        return stepper;
    }

    public Object getState() {
        return state;
    }

    public static <T> FStream<T> fstream(List<T> l){
        Function<Object, Step> nextStream = x -> {
            List aux = (List) x;

            if(aux.isEmpty()){
                return new Done();
            }
            else{
                List<T> sub = aux.subList(1, aux.size());
                return new Yield<T, List<T>>((T) aux.get(0), sub);
            }
        };

        return new FStream<T>(nextStream, l);
    }

    public List<T> unfstream(){
        ArrayList<T> res = new ArrayList<>();
        Object auxState = this.state;
        boolean over = false;

        while (!over) {
            Step step = this.stepper.apply(auxState);

            if (step instanceof Done) {
                over = true;
            } else if (step instanceof Skip) {
                auxState = step.state;
            } else if (step instanceof Yield) {
                res.add((T) step.elem);
                auxState = step.state;
            }
        }

        return res;
    }

    public <S> FStream<S> mapfs(Function<T,S> funcTtoS){
        Function<Object, Step> nextMap = x -> {
            Step aux = this.stepper.apply(x);

            if(aux instanceof Done){
                return new Done();
            }
            else if(aux instanceof Skip){
                return new Skip<>(aux.state);
            }
            else if(aux instanceof Yield){
                return new Yield<>(funcTtoS.apply((T) aux.elem), aux.state);
            }

            return null;
        };

        return new FStream<S>(nextMap, this.state);
    }

    public FStream<T> filterfs(Predicate p){
        Function<Object, Step> nextFilter = x -> {
            Step aux = this.stepper.apply(x);

            if(aux instanceof Done){
                return new Done();
            }
            else if(aux instanceof Skip){
                return new Skip<>(aux.state);
            }
            else if(aux instanceof Yield){
                if(p.test(aux.elem)){
                    return new Yield<>((T) aux.elem, aux.state);
                }
                else{
                    return new Skip<>(aux.state);
                }
            }

            return null;
        };

        return new FStream<T>(nextFilter, this.state);
    }

    public <S> S foldl(BiFunction<S,T,S> f, S value) {
        Object auxState = this.state;
        boolean over = false;

        while (!over) {
            Step step = stepper.apply(auxState);

            if (step instanceof Done) {
                over = true;
            } else if (step instanceof Skip) {
                auxState = step.state;
            } else if (step instanceof Yield) {
                value = f.apply(value, (T) step.elem);
                auxState = step.state;
            }
        }

        return value;
    }

    public Optional<T> foldl1(BiFunction<T,T,T> f){
        Object auxState = this.state;
        boolean foundFirst = false, over = false;
        T value = null;

        while (!foundFirst) {
            Step step = stepper.apply(auxState);

            if (step instanceof Done) {
                over = foundFirst = true;
            } else if (step instanceof Skip) {
                auxState = step.state;
            } else if (step instanceof Yield) {
                foundFirst = true;
                value = (T) step.elem;
                auxState = step.state;
            }
        }

        while (!over) {
            Step step = stepper.apply(auxState);

            if (step instanceof Done) {
                over = true;
            } else if (step instanceof Skip) {
                auxState = step.state;
            } else if (step instanceof Yield) {
                value = f.apply(value, (T) step.elem);
                auxState = step.state;
            }
        }

        return value == null ? Optional.empty() : Optional.of(value);
    }

    public T head(){
        Object auxState = this.state;
        boolean over = false;
        T res = null;

        while(!over){
            Step step = stepper.apply(auxState);

            if (step instanceof Done) {
                over = true;
            } else if (step instanceof Skip) {
                auxState = step.state;
            } else if (step instanceof Yield) {
                res = (T) step.elem;
                over = true;
            }
        }

        return res;
    }

    public boolean isEmpty(){
        Object auxState = this.state;
        boolean empty = true, over = false;

        while(!over){
            Step step = stepper.apply(auxState);

            if (step instanceof Done) {
                over = true;
            } else if (step instanceof Skip) {
                auxState = step.state;
            } else if (step instanceof Yield) {
                empty = false;
                over = true;
            }
        }

        return empty;
    }

    public static <T> List<T> map(Function f, ArrayList<T> l){
        return fstream(l).mapfs(f).unfstream();
    }

    public static void main(String[] args){
        /*final int SIZE = 6;
        ArrayList<Integer> l = new ArrayList<>();
        for(int i = 1; i < SIZE; i++){
            l.add(i);
        }
        l.add(1);

        FStream<Integer> fsOrig = fstream(l);
        System.out.println(fsOrig.state);
        List<Integer> lOrig = fsOrig.unfstream();
        System.out.println(lOrig);
        System.out.println("Test for reference equality: " + (lOrig == l));

        System.out.println("Mapping...");
        Function<Integer, Integer> f = n -> n + 30;
        FStream<Integer> fsMap = fsOrig.mapfs(f);
        List<Integer> lMapped = fsMap.unfstream();
        System.out.println("Mapped: " + lMapped);
        System.out.println("Original: " + lOrig);

        System.out.println("Filtering...");
        Predicate<Integer> p = n -> n < 3;
        FStream<Integer> fsFilter = fsOrig.filterfs(p);
        List<Integer> lFiltered = fsFilter.unfstream();
        System.out.println("Filtered: " + lFiltered);
        System.out.println("Original: " + lOrig);

        Function<Integer,Integer> inc = x -> x + 1;
        System.out.println("Mapping chained...");
        FStream<Integer> fsInc = fsOrig.mapfs(inc).mapfs(inc);
        List<Integer> lInc = fsInc.unfstream();
        System.out.println(lInc);
        System.out.println("Mapping merged...");
        FStream<Integer> fsInc2 = fsOrig.mapfs(inc.andThen(inc));
        List<Integer> lInc2 = fsInc2.unfstream();
        System.out.println(lInc2);

        System.out.println("Appending...");
        ArrayList<Integer> lB = new ArrayList<>();
        for(int i = 6; i < SIZE+6; i++){
            lB.add(i);
        }
        FStream<Integer> fsOrigB = fstream(lB);
        Predicate<Integer> p2 = n -> n >= 4;
        List<Integer> lAppended = fsOrig.appendfs(fsOrigB).appendfs(fsOrigB).mapfs(inc).filterfs(p2).unfstream();
        System.out.println(lAppended);

        System.out.println("Zipping...");
        ArrayList<String> lStrings = new ArrayList<>(Arrays.asList(new String[]{"hello", "ola", "hola", "ciao", "hallo"}));
        FStream<String> fsString = fstream(lStrings);
        List<Pair<Integer,String>> lZipped = fsOrig.mapfs(inc).filterfs(p2).zipfs(fsString).unfstream();
        System.out.println(lZipped);

        System.out.println("ConcatMapping...");
        ArrayList<Integer> lInts = new ArrayList<>(Arrays.asList(new Integer[]{1, 2, 3}));
        FStream<Integer> fsInts = fstream(lInts);
        System.out.println(fsInts.concatMap(FStream::until).unfstream());

        System.out.println("Foldr...");
        System.out.println(fsInts.filterfs(x -> (int) x >= 2).foldr(((x,y) -> x-y), 0));
        System.out.println("FoldrLoop...");
        System.out.println(fsInts.filterfs(x -> (int) x >= 2).foldrLoop(((x,y) -> x-y), 0));
        System.out.println("Foldl...");
        System.out.println(fsInts.filterfs(x -> (int) x >= 2).foldl(((x,y) -> x-y), 0));

        System.out.println("GHC Optimizations...");
        ArrayList<Integer> xsList = new ArrayList<>(Arrays.asList(new Integer[]{1, 2, 3, 4, 5}));
        ArrayList<Integer> ysList = new ArrayList<>(Arrays.asList(new Integer[]{6, 7, 8, 9, 10}));
        FStream<Integer> xsFs = fstream(xsList);
        FStream<Integer> ysFs = fstream(ysList);
        System.out.println(xsFs.appendfs(ysFs).foldl((x,y) -> x + y, 0));*/

        System.out.println("Foldl1...");
        ArrayList<Integer> foldl1List = new ArrayList<>(Arrays.asList(new Integer[]{}));
        System.out.println(fstream(foldl1List).foldl((a,b) -> a+b, 0));
        System.out.println(fstream(foldl1List).foldl1((a,b) -> a+b));
    }
}