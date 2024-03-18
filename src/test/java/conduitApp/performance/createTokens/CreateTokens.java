package conduitApp.performance.createTokens;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import com.intuit.karate.Runner;

public class CreateTokens {

    private static final ArrayList<String> tokens = new ArrayList<>();
    private static final AtomicInteger counter = new AtomicInteger();

    private static String[] emails = {
            "maxi2@gmail.com",
            "maxi3@gmail.com"
    };

    public static String getNextToken(){
        return tokens.get(counter.getAndIncrement() % tokens.size());
    }

    public static void createAccessTokens() {

        for (String email : emails) {
            Map<String, Object> account = new HashMap<>();
            account.put("userEmail", email);
            account.put("userPassword", "123456");
            account.put("apiUrl", "https://conduit-api.bondaracademy.com/api/");
            Map<String, Object> result = Runner.runFeature("classpath:helpers/CreateToken.feature", account, false);
            tokens.add(result.get("authToken").toString());
        }
    }
}
