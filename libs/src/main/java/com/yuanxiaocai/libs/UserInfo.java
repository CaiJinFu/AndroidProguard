package com.yuanxiaocai.libs;

/**
 * 用户信息类
 *
 * @author 猿小蔡
 * @since 2025/7/20
 */
public class UserInfo {

    private String name;

    private int age;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }

    @Override
    public String toString() {
        return "UserInfo{" + "name='" + name + '\'' + ", age=" + age + '}';
    }

}
